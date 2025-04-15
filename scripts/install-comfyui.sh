#!/usr/bin/env bash
set -e
if [ ! -f ../.settings ]; then
    printf "[!] Please run install.sh first!\n"
else
    source ../.settings
fi
if [ -d "$COMFYUI_INSTALLER_DIR/ComfyUI" ]; then
    printf "[!] [\033[0;32mComfyUI\033[m] already exists, updating.\n"
    cd "$COMFYUI_INSTALLER_DIR"/ComfyUI || exit 1
    git pull
else
    printf "[*] Installing [\033[0;32mComfyUI\033[m] and [\033[0;32mComfyUI-Manager\033[m]\n"
    cd "$COMFYUI_INSTALLER_DIR" || exit 1
    git clone https://github.com/comfyanonymous/ComfyUI
fi

cd "$COMFYUI_INSTALLER_DIR"/ComfyUI || exit 1
python -m venv "$VIRTUAL_ENV"
source "$VIRTUAL_ENV/bin/activate"

if [ "$GPU" == "AMD" ]; then

    # You might want to try using a newer or nightly version here if ComfyUI is not working for you.
    # pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.2.4
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2
    pip install -r requirements.txt
    pip install -r custom_nodes/comfyui-manager/requirements.txt

fi
if [ "$GPU" == "NVIDIA" ]; then
    CUDA_VERSION=$(cat /usr/local/cuda/version.json | jq .cuda.version)
    cwhl=$(echo "$CUDA_VERSION" | sed 's|"||g' | sed 's|\.||g' | cut -c1-3)
    printf "[*] Found CUDA [\033[0;32m%s\033[m]\n" "$CUDA_VERSION"
    printf "[*] Using pytorch [\033[0;32mcu%s\033[m]\n" "$cwhl"

    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu$cwhl
    # You might want to try using a newer or nightly version here if ComfyUI is not working for you.
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu$cwhl
    pip install -r requirements.txt
    pip install -r custom_nodes/comfyui-manager/requirements.txt

fi
# find custom_nodes/ -type f -name 'requirements.txt' -exec pip install -r {} \;

# pip install deepdiff pattern tensorflow xformers

CREATE_RUNFILES() {
    printf "[*] Creating %s/scripts/run_gpu.sh.\n" "$COMFYUI_INSTALLER_DIR"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"
#!/bin/bash
cd "$COMFYUI_DIR" || exit 1
source "$VIRTUAL_ENV/bin/activate"
python main.py --listen 0.0.0.0 --preview-method auto
EOF
    chmod +x "$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"

    printf "[*] Creating %s/scripts/run_cpu.sh.\n" "$COMFYUI_INSTALLER_DIR"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
#!/bin/bash
cd "$COMFYUI_DIR" || exit 1
source "$VIRTUAL_ENV/bin/activate"
python main.py --listen 0.0.0.0 --preview-method auto --cpu
EOF
    chmod +x "$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
}
ADD_TO_DESKTOP() {
    printf "[*] Creating %s/scripts/ComfyUI.desktop" "$COMFYUI_INSTALLER_DIR"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/ComfyUI.desktop"
[Desktop Entry]
Name=ComfyUI
Path=$COMFYUI_DIR/
Exec=$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh
Comment=A powerful and modular stable diffusion GUI with a graph/nodes interface.
Terminal=true
Icon=$COMFYUI_INSTALLER_DIR/graphics/comfyui.svg
Type=Application
NoDisplay=false
EOF
    cp "$COMFYUI_INSTALLER_DIR/scripts/ComfyUI.desktop" ~/.local/share/applications/ComfyUI.desktop
    chmod +x ~/.local/share/applications/ComfyUI.desktop

    printf "[*] Adding ComfyUI to your desktop.\n"
    exec_path="$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"   # Launch script
    icon_path="$COMFYUI_INSTALLER_DIR/graphics/comfyui.svg" # ComfyUI Icon
    desktop-file-install \
        --dir="$HOME/.local/share/applications/" \
        --set-key=Path \
        --set-value="$PWD" \
        --set-key=Exec \
        --set-value="$exec_path" \
        --set-icon="$icon_path" \
        "$COMFYUI_INSTALLER_DIR/scripts/ComfyUI.desktop"
}
CREATE_RUNFILES
ADD_TO_DESKTOP
