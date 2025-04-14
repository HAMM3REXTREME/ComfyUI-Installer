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
    printf "[*] Found CUDA [\033[0;32m$CUDA_VERSION\033[m]\n"
    printf "[*] Using pytorch [\033[0;32mcu$cwhl\033[m]\n"

    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu$cwhl
    # You might want to try using a newer or nightly version here if ComfyUI is not working for you.
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu$cwhl
    pip install -r requirements.txt
    pip install -r custom_nodes/comfyui-manager/requirements.txt

fi
# find custom_nodes/ -type f -name 'requirements.txt' -exec pip install -r {} \;

# pip install deepdiff pattern tensorflow xformers

cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"
#!/bin/bash
cd "$COMFYUI_DIR" || exit 1
source "$VIRTUAL_ENV/bin/activate"
python main.py --listen 0.0.0.0 --preview-method auto
EOF

cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
#!/bin/bash" >"$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
cd "$COMFYUI_DIR" || exit 1
source "$VIRTUAL_ENV/bin/activate"
python main.py --listen 0.0.0.0 --preview-method auto --cpu
EOF
