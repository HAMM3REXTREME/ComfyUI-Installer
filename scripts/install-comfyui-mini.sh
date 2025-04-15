#!/usr/bin/env bash
set -e
if [ ! -f .settings ]; then
    printf "[!] Please run install.sh first!\n"
    exit 1
else
    source .settings
fi
if [ -d "$COMFYUI_DIR/custom_nodes/ComfyUIMini" ]; then
    printf "[!] [\033[0;32mComfyUIMini\033[m] already exists, updating.\n"
    cd "$COMFYUI_DIR/custom_nodes/ComfyUIMini" || exit 1
    git pull >/dev/null 2>&1
    chmod +x ./scripts/update.sh
    ./scripts/update.sh >/dev/null 2>&1
else
    printf "[*] Cloning [\033[0;32mComfyUIMini\033[m]\n"
    git clone https://github.com/ImDarkTom/ComfyUIMini "$COMFYUI_DIR/custom_nodes/ComfyUIMini" >/dev/null 2>&1
    cd "$COMFYUI_DIR/custom_nodes/ComfyUIMini" || exit 1
    chmod +x ./scripts/*.sh
    if ! command -v npm &>/dev/null; then
        printf "[!] [\033[0;32mNPM\033[m] is not installed. Please install NPM and Node.js and try again.\n"
        exit 1
    fi

    printf "[*] Installing dependencies for [\033[0;32mComfyUIMini\033[m]\n"
    npm install >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        printf "[!] Failed to update dependencies. Please check your internet connection and try again.\n"
        exit 1
    fi

    printf "[*] Building ComfyUIMini\n"
    npm run build >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        printf "[!] Build failed. Check the console for more information.\n"
        exit 1
    fi
    printf "[*] Creating config from [\033[0;32mexample.default.json\033[m] with output_dir set to [\033[0;32m%s/output\033[m]\n" "$COMFYUI_DIR"
    cp ./config/default.example.json ./config/default.json
    sed -i "s|path/to/comfyui/output/folder|$COMFYUI_DIR/output|g" ./config/default.json
    printf "[*] Creating workflows symlink\n"
    rm -rf workflows
    ln -s "$COMFYUI_DIR/user/default/workflows" workflows
fi

ADD_TO_DESKTOP() {
    printf "[*] Creating [\033[0;32m%s/scripts/ComfyUIMini.desktop\033[m]\n" "$COMFYUI_INSTALLER_DIR"
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
CREATE_SERVICE() {
    printf "[*] Creating [\033[0;32mComfyUIMini.service\033[m] file.\n"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/ComfyUIMini.service"
[Unit]
Description=ComfyUI Mini Service
After=network.target

[Service]
Type=simple
User=$USER
Group=$USER
WorkingDirectory=$COMFYUI_DIR/custom_nodes/ComfyUIMini
ExecStart=$COMFYUI_DIR/custom_nodes/ComfyUIMini/scripts/start.sh

[Install]
WantedBy=multi-user.target
EOF
    sudo cp "$COMFYUI_INSTALLER_DIR/scripts/ComfyUIMini.service" /etc/systemd/system/ComfyUIMini.service
}

CREATE_SERVICE
ADD_TO_DESKTOP
