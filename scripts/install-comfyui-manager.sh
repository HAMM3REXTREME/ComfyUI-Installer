#!/usr/bin/env bash
set -e
if [ ! -f .settings ]; then
    printf "[!] Please run install.sh first!\n"
    exit 1
else
    source .settings
fi
if [ -d "$COMFYUI_DIR/custom_nodes/comfyui-manager" ]; then
    printf "[!] [\033[0;32mComfyUI-Manager\033[m] already exists, updating.\n"
    cd "$COMFYUI_DIR/custom_nodes/comfyui-manager" || exit 1
    git pull >/dev/null 2>&1
else
    printf "[*] Installing [\033[0;32mComfyUI-Manager\033[m]\n"
    cd "$COMFYUI_DIR/custom_nodes" || exit 1
    git clone https://github.com/ltdrdata/ComfyUI-Manager "$COMFYUI_DIR/custom_nodes/comfyui-manager" >/dev/null 2>&1
fi

cd "$COMFYUI_DIR" || exit 1
python -m venv "$VIRTUAL_ENV"
source "$VIRTUAL_ENV/bin/activate"

pip install -q -r "$COMFYUI_DIR/custom_nodes/comfyui-manager/requirements.txt"
