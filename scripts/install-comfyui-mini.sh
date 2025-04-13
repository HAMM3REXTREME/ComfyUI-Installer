#!/usr/bin/env bash
set -e
if [ ! -f ../.settings ]; then
    printf "[!] Please run install.sh first!\n"
else
    source ../.settings
fi
if [ -d "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini" ]; then
    printf "[!] [\033[0;32mComfyUIMini\033[m] already exists, updating.\n"
    cd "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini" || exit 1
    chmod +x ./scripts/update.sh
    ./scripts/update.sh
else
    printf "[*] Cloning [\033[0;32mComfyUIMini\033[m]\n"
    git clone https://github.com/ImDarkTom/ComfyUIMini "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini" >/dev/null 2>&1
    cd "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini" || exit 1
    chmod +x ./scripts/*.sh
    if ! command -v npm &>/dev/null; then
        printf "[!] [\033[0;32mNPM\033[m] is not installed. Please install NPM and Node.js and try again.\n"
        exit 1
    fi

    printf "[*] Installing dependencies for ComfyUIMini\n"
    npm install
    if [ $? -ne 0 ]; then
        printf "[!] Failed to update dependencies. Please check your internet connection and try again.\n"
        exit 1
    fi

    printf "[*] Building ComfyUIMini\n"
    npm run build
    if [ $? -ne 0 ]; then
        printf "[!] Build failed. Check the console for more information.\n"
        exit 1
    fi
    printf "[*] Creating config from example.default.json with output_dir set to $COMFYUI_DIR/output\n"
    cp ./config/default.example.json ./config/default.json
    sed -i "s|path/to/comfyui/output/folder|$COMFYUI_DIR/output|g" ./config/default.json
    printf "[*] Creating workflows symlink\n"
    rm -rf workflows
    ln -s "$COMFYUI_DIR/user/default/workflows" workflows
fi
