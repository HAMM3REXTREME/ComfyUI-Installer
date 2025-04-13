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
    source .settings
else
    printf "[*] [\033[0;32m.settings\033[m] file found, loading.\n"
    source .settings
fi
INSTALL_COMFYUI() {
    if [ -d ComfyUI ]; then
        printf "[!] [\033[0;32mComfyUI\033[m] already exists, updating.\n"
        git pull
    else
        # wget https://github.com/ltdrdata/ComfyUI-Manager/raw/main/scripts/install-comfyui-venv-linux.sh
        # wget -O - https://github.com/ltdrdata/ComfyUI-Manager/raw/main/scripts/install-comfyui-venv-linux.sh | bash
        # bash <(curl -Ls https://github.com/ltdrdata/ComfyUI-Manager/raw/main/scripts/install-comfyui-venv-linux.sh)
        chmod +x scripts/*.sh
        if [ "$GPU" == "NVIDIA" ]; then
            printf "\n[*] Installing [\033[0;32mComfyUI\033[m], [\033[0;32mComfyUI-Manager\033[m] and [\033[0;32mComfyUIMini\033[m] for [\033[0;32m$GPU\033[m]\n"
            ./scripts/install-comfyui-nvidia-venv-linux.sh >/dev/null 2>&1
        fi
        if [ "$GPU" == "AMD" ]; then
            printf "\n[*] Installing [\033[0;32mComfyUI\033[m], [\033[0;32mComfyUI-Manager\033[m] and [\033[0;32mComfyUIMini\033[m] for [\033[0;32m$GPU\033[m]\n"
            ./scripts/install-comfyui-amd-venv-linux.sh >/dev/null 2>&1
        fi
    fi
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
CREATE_SERVICES() {
    printf "[*] Creating [\033[0;32mComfyUI.service\033[m] file.\n"
    cat <<EOF >"scripts/ComfyUI.service"
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

    printf "[*] Creating [\033[0;32mComfyUIMini.service\033[m] file.\n"
    cat <<EOF >"scripts/ComfyUIMini.service"
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
    printf "[*] [\033[0;32mService Files\033[m] created, now adding to systemd.\n"
    sudo cp scripts/ComfyUI.service /etc/systemd/system/
    sudo cp scripts/ComfyUIMini.service /etc/systemd/system/
    sudo systemctl daemon-reload
}

INST_DEPS
INSTALL_COMFYUI
LINKING_DIRS
CREATE_SERVICES

chmod +x "$COMFYUI_INSTALLER_DIR/scripts/"*.sh
chmod +x "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini/scripts/"*.sh

printf "\033[32mFinished!\033[0m\n\n"
printf "\033[32mTo Launch ComfyUI manually, use: 'scripts/run_gpu.sh' or 'scripts/run_cpu.sh' \033[0m\n"
printf "\033[32mTo launch ComfyUIMini manually, use: 'ComfyUI/custom_nodes/ComfyUIMini/scripts/start.sh' \033[0m\n\n"
printf "\033[32mTo start ComfyUI as systemd service, run: 'sudo systemctl start ComfyUI.service' \033[0m\n"
printf "\033[32mTo start ComfyUIMini as systemd service, run: 'sudo systemctl start ComfyUIMini.service' \033[0m\n\n"
printf "\033[32mTo enable ComfyUI service at boot, run: 'sudo systemctl enable ComfyUI.service' \033[0m\n"
printf "\033[32mTo enable ComfyUIMini service at boot, run: 'sudo systemctl enable ComfyUIMini.service' \033[0m\n\n"
printf "\033[32mTo view the logs of ComfyUI, run: 'tail -f ComfyUI/user/comfyui.log' \033[0m\n"
printf "\033[32mTo view the logs of ComfyUI, run: 'multitail -f ComfyUI/user/comfyui.log' \033[0m\n\n"
printf "\033[32mTo view the logs of ComfyUI, run: 'journalctl -f -u ComfyUI.service' \033[0m\n"
printf "\033[32mTo view the logs of ComfyUIMini, run: 'journalctl -f -u ComfyUIMini.service' \033[0m\n\n"

printf "\033[32mStarting the ComfyUI.service now.' \033[0m\n"
sudo systemctl start ComfyUI
printf "\033[32mStarting the ComfyUIMini.service now.' \033[0m\n"
sudo systemctl start ComfyUIMini
printf "\033[32mOpen a browser and go to: 'http://0.0.0.0:8188' for ComfyUI \033[0m\n"
printf "\033[32mOpen a browser and go to: 'http://0.0.0.0:3000' for ComfyUIMini \033[0m\n"

# xdg-open http://0.0.0.0:3000
# xdg-open http://0.0.0.0:8188
multitail -f "$COMFYUI_INSTALLER_DIR/ComfyUI/user/comfyui.log"
