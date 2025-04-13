#!/usr/bin/env bash
set -e
if [ ! -f ../.settings ]; then
    printf "[!] Please run install.sh first!\n"
else
    source ../.settings
fi
if [ -d "$COMFYUI_INSTALLER_DIR/custom_nodes/comfyui-manager" ]; then
    printf "[!] [\033[0;32mComfyUI-Manager\033[m] already exists, updating.\n"
    cd "$COMFYUI_INSTALLER_DIR"/custom_nodes/comfyui-manager || exit 1
    git pull
else
    printf "[*] Installing [\033[0;32mComfyUI-Manager\033[m]\n"
    cd "$COMFYUI_DIR"/custom_nodes || exit 1
    git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager
fi

cd "$COMFYUI_INSTALLER_DIR"/ComfyUI || exit 1
python -m venv "$VIRTUAL_ENV"
source "$VIRTUAL_ENV/bin/activate"

pip install -r custom_nodes/comfyui-manager/requirements.txt
