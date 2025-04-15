#!/usr/bin/env bash
# set -e
COMFYUI_INSTALLER_DIR=""
COMFYUI_DIR=""
GPU=""
VIRTUAL_ENV=""

INST_DEPS() {
    if ! command -v whiptail 2>&1 >/dev/null; then
        printf "[*] Installing [\033[0;32mwhiptail\033[m].\n"
        sudo apt update
        sudo apt install whiptail -y
    fi
    if ! command -v git 2>&1 >/dev/null; then
        printf "[*] Installing [\033[0;32mgit\033[m].\n"
        sudo apt update
        sudo apt install git -y
    fi
    if ! command -v python3 2>&1 >/dev/null; then
        printf "[*] Installing [\033[0;32mpython3\033[m].\n"
        sudo apt update
        sudo apt install python3 python3-venv -y
    fi
    if ! command -v xterm 2>&1 >/dev/null; then
        printf "[*] Installing [\033[0;32mxterm\033[m].\n"
        sudo apt update
        sudo apt install xterm -y
    fi
    if ! command -v multitail 2>&1 >/dev/null; then
        printf "[*] Installing [\033[0;32mmultitail\033[m].\n"
        sudo apt update
        sudo apt install multitail -y
    fi
}
ASK_USER_INPUT() {
    eval "$(resize)"

    COMFYUI_INSTALLER_DIR=$(whiptail --title "Installer directory." --inputbox "Enter the directory where the installer currently is located. (Default: $PWD)" $LINES $COLUMNS "$PWD" 3>&1 1>&2 2>&3)
    COMFYUI_DIR=$(whiptail --title "Gpu Selection." --inputbox "Where should ComfyUI be installed? (Default: $PWD/ComfyUI)" $LINES $COLUMNS "$PWD/ComfyUI" 3>&1 1>&2 2>&3)
    BACKUP_DIR=$(whiptail --title "Backup directory." --inputbox "Where should the backup directory be created? (Default: $PWD/backup)" $LINES $COLUMNS "$PWD/backup" 3>&1 1>&2 2>&3)
    GPU=$(whiptail --menu "Select the GPU type." $LINES $COLUMNS $((LINES - 8)) \
        "NVIDIA" "For Nvidia Gpu's." \
        "AMD" "For AMD Gpu's." 3>&1 1>&2 2>&3)
    VIRTUAL_ENV=$(whiptail --inputbox "Where should the virtual environment directory be created? (Default: $PWD/ComfyUI/venv)" $LINES $COLUMNS "$PWD/ComfyUI/venv" 3>&1 1>&2 2>&3)
    if [ -z "$COMFYUI_INSTALLER_DIR" ]; then
        COMFYUI_INSTALLER_DIR=$PWD
    fi
    if [ -z "$COMFYUI_DIR" ]; then
        COMFYUI_DIR=$PWD/ComfyUI
    fi
    if [ -z "$GPU" ]; then
        GPU="NVIDIA"
    fi
    if [ -z "$VIRTUAL_ENV" ]; then
        VIRTUAL_ENV=$PWD/ComfyUI/venv
    fi
    cat <<EOF >.settings
# The directory where the installer is located:
export COMFYUI_INSTALLER_DIR=$PWD

# The directory where the ComfyUI is located:
export COMFYUI_DIR=$PWD/ComfyUI

# The type of GPU to use:
export GPU=$GPU

# The directory where the backups are located:
export BACKUP_DIR=/media/$USER/DATA/ai-stuff

# The virtual environment directory:
export VIRTUAL_ENV=$PWD/ComfyUI/venv
EOF
    printf "[*] Created [\033[0;32m.settings\033[m] file with the following contents:\n\n"
    cat .settings
}

if [ ! -f .settings ]; then
    printf "[*] [\033[0;32m.settings\033[m] file not found, creating.\n"
    ASK_USER_INPUT
    EXIT
else
    printf "[*] [\033[0;32m.settings\033[m] file found, loading.\n"
    source .settings
fi
INSTALL_COMFYUI() {
    if [ -d ComfyUI ]; then
        printf "[!] [\033[0;32mComfyUI\033[m] already exists, updating.\n"
        cd ComfyUI || exit 1
        git pull
    else
        printf "[*] Installing [\033[0;32mComfyUI\033[m].\n"
        chmod +x scripts/*.sh
        ./scripts/install-comfyui.sh >/dev/null 2>&1
        printf "[*] [\033[0;32mComfyUI\033[m] installed.\n"
    fi
    printf "[*] Creating [\033[0;32mComfyUI.service\033[m] file.\n"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/ComfyUI.service"
[Unit]
Description=ComfyUI Service
After=network.target

[Service]
Restart=on-failure
RestartSec=5s
Type=simple
User=$USER
Group=$USER
WorkingDirectory=$COMFYUI_DIR
ExecStart=$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh

[Install]
WantedBy=multi-user.target
EOF
    sudo cp "$COMFYUI_INSTALLER_DIR/scripts/ComfyUI.service" /etc/systemd/system/ComfyUI.service
}

INSTALL_COMFYUI_MANAGER() {
    if [ -d ComfyUI/custom_nodes/comfyui-manager ]; then
        printf "[!] [\033[0;32mComfyUI-Manager\033[m] already exists, updating.\n"
        cd ComfyUI/custom_nodes/comfyui-manager || exit 1
        git pull
    else
        printf "[*] Installing [\033[0;32mComfyUI-Manager\033[m].\n"
        chmod +x scripts/*.sh
        ./scripts/install-comfyui-manager.sh >/dev/null 2>&1
        printf "[*] [\033[0;32mComfyUI-Manager\033[m] installed.\n"
    fi
}
INSTALL_COMFYUI_MINI() {
    if [ -d ComfyUI/custom_nodes/ComfyUIMini ]; then
        printf "[!] [\033[0;32mComfyUIMini\033[m] already exists, updating.\n"
        cd ComfyUI/custom_nodes/ComfyUIMini || exit 1
        git pull
        chmod +x ./scripts/*.sh
        ./scripts/update.sh >/dev/null 2>&1
    else
        printf "[*] Installing [\033[0;32mComfyUIMini\033[m].\n"
        chmod +x scripts/*.sh
        ./scripts/install-comfyui-mini.sh >/dev/null 2>&1
        printf "[*] [\033[0;32mComfyUIMini\033[m] installed.\n"
    fi
    printf "[*] Creating [\033[0;32mComfyUIMini.service\033[m] file.\n"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/ComfyUIMini.service"
[Unit]
Description=ComfyUI Mini Service
After=network.target

[Service]
Type=simple
User=$USER
Group=$USER
WorkingDirectory=$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini
ExecStart=$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini/scripts/start.sh

[Install]
WantedBy=multi-user.target
EOF
    sudo cp "$COMFYUI_INSTALLER_DIR/scripts/ComfyUIMini.service" /etc/systemd/system/ComfyUIMini.service
}
LINKING_DIRS() {
    if [ ! -d "$BACKUP_DIR" ]; then
        printf "[*] [\033[0;32mBackup\033[m] directory not found, creating.\n"
        mkdir -p "$BACKUP_DIR"
        mv "$COMFYUI_INSTALLER_DIR/web" "$BACKUP_DIR"
        mv "$COMFYUI_INSTALLER_DIR/user" "$BACKUP_DIR"
        mv "$COMFYUI_INSTALLER_DIR/output" "$BACKUP_DIR"
        mv "$COMFYUI_INSTALLER_DIR/models" "$BACKUP_DIR"
        mv "$COMFYUI_INSTALLER_DIR/input" "$BACKUP_DIR"
        mv "$COMFYUI_INSTALLER_DIR/custom_nodes" "$BACKUP_DIR"
        printf "[*] [\033[0;32mBackup\033[m] directory created.\n"
        printf "[*] [\033[0;32ComfyUI/webm\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\web\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/user\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\user\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/output\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\output\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/models\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\models\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/input\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\input\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/custom_nodes\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\custom_nodes\033[m]\n"
    fi
    if [ -d "$COMFYUI_INSTALLER_DIR/web" ]; then
        rm -rf "$COMFYUI_INSTALLER_DIR/web"
    fi
    if [ -d "$COMFYUI_INSTALLER_DIR/user" ]; then
        rm -rf "$COMFYUI_INSTALLER_DIR/user"
    fi
    if [ -d "$COMFYUI_INSTALLER_DIR/output" ]; then
        rm -rf "$COMFYUI_INSTALLER_DIR/output"
    fi
    if [ -d "$COMFYUI_INSTALLER_DIR/models" ]; then
        rm -rf "$COMFYUI_INSTALLER_DIR/models"
    fi
    if [ -d "$COMFYUI_INSTALLER_DIR/input" ]; then
        rm -rf "$COMFYUI_INSTALLER_DIR/input"
    fi
    if [ -d "$COMFYUI_INSTALLER_DIR/custom_nodes" ]; then
        rm -rf "$COMFYUI_INSTALLER_DIR/custom_nodes"
    fi
    ln -sf "$BACKUP_DIR/web" "$COMFYUI_INSTALLER_DIR/ComfyUI"
    ln -sf "$BACKUP_DIR/user" "$COMFYUI_INSTALLER_DIR/ComfyUI"
    ln -sf "$BACKUP_DIR/output" "$COMFYUI_INSTALLER_DIR/ComfyUI"
    ln -sf "$BACKUP_DIR/models" "$COMFYUI_INSTALLER_DIR/ComfyUI"
    ln -sf "$BACKUP_DIR/input" "$COMFYUI_INSTALLER_DIR/ComfyUI"
    ln -sf "$BACKUP_DIR/custom_nodes" "$COMFYUI_INSTALLER_DIR/ComfyUI"
}
START_COMFYUI_SERVICE() {
    printf "\033[32mStarting ComfyUI.service.' \033[0m\n"
    sudo systemctl daemon-reload
    sudo systemctl start ComfyUI
}
START_COMFYUIMINI_SERVICE() {
    printf "\033[32mStarting ComfyUIMini.service.' \033[0m\n"
    sudo systemctl daemon-reload
    sudo systemctl start ComfyUIMini
}
ADD_TO_DESKTOP() {
    printf "[*] Adding ComfyUI to desktop.\n"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/ComfyUI.desktop"
[Desktop Entry]
Name=ComfyUI
Path=$COMFYUI_INSTALLER_DIR/ComfyUI/
Exec=$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh
Comment=A powerful and modular stable diffusion GUI with a graph/nodes interface.
Terminal=true
Icon=$COMFYUI_INSTALLER_DIR/graphics/comfyui.svg
Type=Application
NoDisplay=false
EOF
    cp "$COMFYUI_INSTALLER_DIR/scripts/ComfyUI.desktop" ~/.local/share/applications/ComfyUI.desktop
    chmod +x ~/.local/share/applications/ComfyUI.desktop
    printf "[*] Adding ComfyUIMini to desktop.\n"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/ComfyUIMini.desktop"
[Desktop Entry]
Name=ComfyUIMini
Path=$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini/
Exec=$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini/scripts/start.sh
Comment=A powerful and modular stable diffusion GUI with a graph/nodes interface.
Terminal=true
Icon=$COMFYUI_INSTALLER_DIR/graphics/comfyui.svg
Type=Application
NoDisplay=false
EOF
    cp "$COMFYUI_INSTALLER_DIR/scripts/ComfyUIMini.desktop" ~/.local/share/applications/ComfyUIMini.desktop
    chmod +x ~/.local/share/applications/ComfyUIMini.desktop
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
CREATE_RUNFILES() {
    printf "[*] Adding runfile to scripts.\n"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"
#!/bin/bash
cd "$COMFYUI_INSTALLER_DIR/ComfyUI" || exit 1
source venv/bin/activate
python main.py --listen 0.0.0.0 --preview-method auto
EOF
    chmod +x "$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"
    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
#!/bin/bash
cd "$COMFYUI_INSTALLER_DIR/ComfyUI"
source venv/bin/activate
python main.py --listen 0.0.0.0 --preview-method auto --cpu
EOF
    chmod +x "$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
}
INST_DEPS
INSTALL_COMFYUI
LINKING_DIRS
INSTALL_COMFYUI_MANAGER
INSTALL_COMFYUI_MINI
ADD_TO_DESKTOP
CREATE_RUNFILES

chmod +x "$COMFYUI_INSTALLER_DIR/scripts/"*.sh
chmod +x "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini/scripts/"*.sh

START_COMFYUI_SERVICE
START_COMFYUIMINI_SERVICE

printf "\033[32mFinished!\033[0m\n\n"
printf "\033[32mTo Launch ComfyUI manually, use: 'scripts/run_gpu.sh' or 'scripts/run_cpu.sh' \033[0m\n"
printf "\033[32mTo Launch ComfyUIMini manually, use: 'ComfyUI/custom_nodes/ComfyUIMini/scripts/start.sh' \033[0m\n\n"

printf "\033[32mTo start ComfyUI as systemd service, run: 'sudo systemctl start ComfyUI.service' \033[0m\n"
printf "\033[32mTo start ComfyUIMini as systemd service, run: 'sudo systemctl start ComfyUIMini.service' \033[0m\n\n"

printf "\033[32mTo enable ComfyUI service at boot, run: 'sudo systemctl enable ComfyUI.service' \033[0m\n"
printf "\033[32mTo enable ComfyUIMini service at boot, run: 'sudo systemctl enable ComfyUIMini.service' \033[0m\n\n"

printf "\033[32mTo view the logs of ComfyUI, run: 'multitail -f ComfyUI/user/comfyui.log' \033[0m\n\n"
printf "\033[32mTo view the logs of ComfyUI, run: 'journalctl -f -u ComfyUI.service' \033[0m\n"

printf "\033[32mTo view the logs of ComfyUIMini, run: 'journalctl -f -u ComfyUIMini.service' \033[0m\n\n"

printf "\033[32mOpen a browser and go to: 'http://0.0.0.0:8188' for ComfyUI \033[0m\n"
printf "\033[32mOpen a browser and go to: 'http://0.0.0.0:3000' for ComfyUIMini \033[0m\n"

# xdg-open http://0.0.0.0:3000
# xdg-open http://0.0.0.0:8188
multitail -f "$COMFYUI_INSTALLER_DIR/ComfyUI/user/comfyui.log"
