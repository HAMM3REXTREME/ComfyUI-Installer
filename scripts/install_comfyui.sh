#!/usr/bin/env bash
set -e
if [ -n "$COMFYUI_INSTALLER_DIR" ]; then
    if [ -f ".settings" ]; then
        source .settings
    elif [ -f "scripts/.settings" ]; then
        source scripts/.settings
    else
        echo "[!] No settings file found. Please run the setup script first."
        exit 1
    fi
fi

cd "$COMFYUI_INSTALLER_DIR" || exit 1
python -m venv "$VIRTUAL_ENV"
source "$VIRTUAL_ENV/bin/activate"

if [ -d "$COMFYUI_INSTALLER_DIR/ComfyUI" ]; then
    pip install -q comfy-cli
    comfy --install-completion
    comfy --workspace="$COMFYUI_DIR" install --restore
else
    pip install -q comfy-cli
    comfy --install-completion
    comfy --workspace="$COMFYUI_DIR" install
fi

# find custom_nodes/ -type f -name 'requirements.txt' -exec pip install -r {} \;

# pip install deepdiff pattern tensorflow xformers
CREATE_RUNFILES() {
    rncmd_gpu="comfy launch -- --listen 0.0.0.0 --preview-method auto"
    rncmd_cpu="comfy launch -- --listen 0.0.0.0 --preview-method auto --cpu"
    printf "[*] Creating [\033[0;32m%s/scripts/run_gpu.sh\033[m]\n" "$COMFYUI_INSTALLER_DIR"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"
#!/bin/bash
cd $COMFYUI_DIR || exit 1
source $VIRTUAL_ENV/bin/activate
$rncmd_gpu
EOF
    chmod +x "$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"

    printf "[*] Creating [\033[0;32m%s/scripts/run_cpu.sh.\033[m]\n" "$COMFYUI_INSTALLER_DIR"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
#!/bin/bash
cd $COMFYUI_DIR || exit 1
source $VIRTUAL_ENV/bin/activate
$rncmd_cpu
EOF
    chmod +x "$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
}
ADD_TO_DESKTOP() {
    printf "[*] Creating [\033[0;32m%s/scripts/ComfyUI.desktop\033[m]\n" "$COMFYUI_INSTALLER_DIR"
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
if [ -f "$COMFYUI_INSTALLER_DIR/scripts/linker.sh" ]; then
    "$COMFYUI_INSTALLER_DIR/scripts/linker.sh"
fi
printf "[*] [\033[0;32mComfyUI\033[m] installation complete.\n"

