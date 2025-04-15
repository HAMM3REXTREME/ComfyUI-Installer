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
    printf "[*] Creating config from example.default.json with output_dir set to %s/output\n" "$COMFYUI_DIR"
    cp ./config/default.example.json ./config/default.json
    sed -i "s|path/to/comfyui/output/folder|$COMFYUI_DIR/output|g" ./config/default.json
    printf "[*] Creating workflows symlink\n"
    rm -rf workflows
    ln -s "$COMFYUI_DIR/user/default/workflows" workflows
fi

ADD_TO_DESKTOP() {
    printf "[*] Creating %s/scripts/ComfyUIMini.desktop" "$COMFYUI_INSTALLER_DIR"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/ComfyUIMini.desktop"
[Desktop Entry]
Name=ComfyUIMini
Path=$COMFYUI_DIR/custom_nodes/ComfyUIMini/
Exec=$COMFYUI_DIR/custom_nodes/ComfyUIMini/scripts/start.sh
Comment=A powerful and modular stable diffusion GUI with a graph/nodes interface.
Terminal=true
Icon=$COMFYUI_INSTALLER_DIR/graphics/comfyui.svg
Type=Application
NoDisplay=false
EOF
    cp "$COMFYUI_INSTALLER_DIR/scripts/ComfyUIMini.desktop" ~/.local/share/applications/ComfyUIMini.desktop
    chmod +x ~/.local/share/applications/ComfyUIMini.desktop

    printf "[*] Adding ComfyUIMini to your desktop.\n"
    exec_path="$COMFYUI_DIR/custom_nodes/ComfyUIMini/scripts/start.sh" # Launch script
    icon_path="$COMFYUI_INSTALLER_DIR/graphics/comfyui.svg"            # ComfyUI Icon
    desktop-file-install \
        --dir="$HOME/.local/share/applications/" \
        --set-key=Path \
        --set-value="$PWD" \
        --set-key=Exec \
        --set-value="$exec_path" \
        --set-icon="$icon_path" \
        "$COMFYUI_INSTALLER_DIR/scripts/ComfyUIMini.desktop"
}
ADD_TO_DESKTOP
