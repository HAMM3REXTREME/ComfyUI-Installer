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

CREATE_SETTINGS_FILE() {
    DEF_COMFYUI_INSTALLER_DIR="$PWD"
    DEF_COMFYUI_DIR="$PWD/ComfyUI"
    DEF_GPU="NVIDIA"
    DEF_VIRTUAL_ENV="$PWD/ComfyUI/venv"

    if [ -z "$COMFYUI_INSTALLER_DIR" ]; then
        COMFYUI_INSTALLER_DIR=$DEF_COMFYUI_INSTALLER_DIR
    fi
    if [ -z "$COMFYUI_DIR" ]; then
        COMFYUI_DIR=$DEF_COMFYUI_DIR
    fi
    if [ -z "$GPU" ]; then
        GPU=$DEF_GPU
    fi
    if [ -z "$VIRTUAL_ENV" ]; then
        VIRTUAL_ENV=$DEF_VIRTUAL_ENV
    fi

    cat <<EOF >.settings
# The directory where the installer is located.
export COMFYUI_INSTALLER_DIR=$PWD

# The directory where the ComfyUI is located.
export COMFYUI_DIR=$PWD/ComfyUI

# The gpu to use.
export GPU=$GPU

# The directory where the backups are located.
export BACKUP_DIR=/media/$USER/DATA/ai-stuff

# The virtual environment directory.
export VIRTUAL_ENV=$PWD/ComfyUI/venv
EOF
    printf "[*] Created [\033[0;32m.settings\033[m] file with the following contents:\n\n"
    cat .settings
}
if [ ! -f .settings ]; then
    printf "[*] [\033[0;32m.settings\033[m] file not found, creating.\n"
    CREATE_SETTINGS_FILE
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
        mv ComfyUI/web "$BACKUP_DIR"
        mv ComfyUI/user "$BACKUP_DIR"
        mv ComfyUI/output "$BACKUP_DIR"
        mv ComfyUI/models "$BACKUP_DIR"
        mv ComfyUI/input "$BACKUP_DIR"
        mv ComfyUI/custom_nodes "$BACKUP_DIR"
        printf "[*] [\033[0;32mBackup\033[m] directory created.\n"
        printf "[*] [\033[0;32ComfyUI/webm\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\web\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/user\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\user\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/output\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\output\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/models\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\models\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/input\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\input\033[m]\n"
        printf "[*] [\033[0;32mComfyUI/custom_nodes\033[m] directory moved to: [\033[0;32m$BACKUP_DIR\custom_nodes\033[m]\n"
    fi
    if [ -d ComfyUI/web ]; then
        rm -rf ComfyUI/web
    fi
    if [ -d ComfyUI/user ]; then
        rm -rf ComfyUI/user
    fi
    if [ -d ComfyUI/output ]; then
        rm -rf ComfyUI/output
    fi
    if [ -d ComfyUI/models ]; then
        rm -rf ComfyUI/models
    fi
    if [ -d ComfyUI/input ]; then
        rm -rf ComfyUI/input
    fi
    if [ -d ComfyUI/custom_nodes ]; then
        rm -rf ComfyUI/custom_nodes
    fi
    ln -s "$BACKUP_DIR/web" ComfyUI
    ln -s "$BACKUP_DIR/user" ComfyUI
    ln -s "$BACKUP_DIR/output" ComfyUI
    ln -s "$BACKUP_DIR/models" ComfyUI
    ln -s "$BACKUP_DIR/input" ComfyUI
    ln -s "$BACKUP_DIR/custom_nodes" ComfyUI
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

INST_DEPS
INSTALL_COMFYUI
LINKING_DIRS
INSTALL_COMFYUI_MANAGER
INSTALL_COMFYUI_MINI
START_COMFYUI_SERVICE
START_COMFYUIMINI_SERVICE

chmod +x "$COMFYUI_INSTALLER_DIR/scripts/"*.sh
chmod +x "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini/scripts/"*.sh

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
