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
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] [\033[0;32mInstaller\033[m] directory: [\033[0;32m%s\033[m]\n" "$COMFYUI_INSTALLER_DIR"
    else
        printf "[!] User selected Cancel."
        exit 1
    fi

    COMFYUI_DIR=$(whiptail --title "Gpu Selection." --inputbox "Where should ComfyUI be installed? (Default: $PWD/ComfyUI)" $LINES $COLUMNS "$PWD/ComfyUI" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] [\033[0;32mComfyUI\033[m] directory: [\033[0;32m%s\033[m]\n" "$COMFYUI_DIR"
    else
        printf "[!] User selected Cancel."
        exit 1
    fi

    VIRTUAL_ENV=$(whiptail --inputbox "Where should the virtual environment directory be created? (Default: $PWD/ComfyUI/venv)" $LINES $COLUMNS "$PWD/ComfyUI/venv" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] [\033[0;32mVirtual Environment\033[m] directory: [\033[0;32m%s\033[m]\n" "$VIRTUAL_ENV"
    else
        printf "[!] User selected Cancel."
        exit 1
    fi

    BACKUP_DIR=$(whiptail --title "Backup directory." --inputbox "Where should the backup directory be created? (Default: $PWD/backup)" $LINES $COLUMNS "$PWD/backup" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] [\033[0;32mBackup\033[m] directory: [\033[0;32m%s\033[m]\n" "$BACKUP_DIR"
    else
        printf "[!] User selected Cancel."
        exit 1
    fi

    GPU=$(whiptail --menu "Select the GPU type." $LINES $COLUMNS $((LINES - 8)) \
        "NVIDIA" "For Nvidia Gpu's." \
        "AMD" "For AMD Gpu's." 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] [\033[0;32mGPU\033[m] type: [\033[0;32m%s\033[m]\n" "$GPU"
    else
        printf "[!] User selected Cancel."
        exit 1
    fi

    USE_SYSTEMD=$(whiptail --title "Use Systemd?" --inputbox "Should a systemd service be created? (Default: true)" $LINES $COLUMNS "true" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] Create systemd service files is set to: [\033[0;32m%s\033[m]\n" "$USE_SYSTEMD"
    else
        printf "[!] User selected Cancel."
        exit 1
    fi
    cat <<EOF >.settings
# The directory where the installer is located:
export COMFYUI_INSTALLER_DIR=$COMFYUI_INSTALLER_DIR
# The directory where the ComfyUI is located:
export COMFYUI_DIR=$COMFYUI_DIR
# The type of GPU to use:
export GPU=$GPU
# The directory where the backups are located:
export BACKUP_DIR=$BACKUP_DIR
# The virtual environment directory:
export VIRTUAL_ENV=$VIRTUAL_ENV
# Use systemd:
export USE_SYSTEMD=$USE_SYSTEMD

EOF
    printf "[*] Created [\033[0;32m.settings\033[m] file with the following contents:\n\n"
    cat .settings
}

if [ ! -f .settings ]; then
    printf "[*] [\033[0;32m.settings\033[m] file not found, creating.\n"
    ASK_USER_INPUT
    printf "[*] Created [\033[0;32m.settings\033[m] file.\n"
    source .settings
else
    printf "[*] [\033[0;32m.settings\033[m] file found, loading.\n"
    source .settings
fi
INSTALL_COMFYUI() {
    if [ -d "$COMFYUI_DIR" ]; then
        printf "[!] [\033[0;32mComfyUI\033[m] already exists, updating.\n"
        cd "$COMFYUI_DIR" || exit 1
        git pull
    else
        "$COMFYUI_INSTALLER_DIR/scripts/install-comfyui.sh"
        printf "[*] [\033[0;32mComfyUI\033[m] installed.\n"
    fi
}

INSTALL_COMFYUI_MANAGER() {
    if [ -d "$COMFYUI_DIR/custom_nodes/comfyui-manager" ]; then
        printf "[!] [\033[0;32mComfyUI-Manager\033[m] already exists, updating.\n"
        cd "$COMFYUI_DIR/custom_nodes/comfyui-manager" || exit 1
        git pull
    else
        "$COMFYUI_INSTALLER_DIR/scripts/install-comfyui-manager.sh"
        printf "[*] [\033[0;32mComfyUI-Manager\033[m] installed.\n"
    fi
}
INSTALL_COMFYUI_MINI() {
    if [ -d "$COMFYUI_DIR/custom_nodes/ComfyUIMini" ]; then
        printf "[!] [\033[0;32mComfyUIMini\033[m] already exists, updating.\n"
        cd "$COMFYUI_DIR/custom_nodes/ComfyUIMini" || exit 1
        git pull
        chmod +x "$COMFYUI_DIR/custom_nodes/ComfyUIMini/scripts/"*.sh
        "$COMFYUI_DIR/custom_nodes/ComfyUIMini/scripts/update.sh"
    else
        "$COMFYUI_INSTALLER_DIR/scripts/install-comfyui-mini.sh"
        printf "[*] [\033[0;32mComfyUIMini\033[m] installed.\n"
    fi
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
        printf "[*] [\033[0;32mComfyUI/web\033[m] directory moved to: [\033[0;32m%s\web\033[m]\n" "$BACKUP_DIR"
        printf "[*] [\033[0;32mComfyUI/user\033[m] directory moved to: [\033[0;32m%s\user\033[m]\n" "$BACKUP_DIR"
        printf "[*] [\033[0;32mComfyUI/output\033[m] directory moved to: [\033[0;32m%s\output\033[m]\n" "$BACKUP_DIR"
        printf "[*] [\033[0;32mComfyUI/models\033[m] directory moved to: [\033[0;32m%s\models\033[m]\n" "$BACKUP_DIR"
        printf "[*] [\033[0;32mComfyUI/input\033[m] directory moved to: [\033[0;32m%s\input\033[m]\n" "$BACKUP_DIR"
        printf "[*] [\033[0;32mComfyUI/custom_nodes\033[m] directory moved to: [\033[0;32m%s\custom_nodes\033[m]\n" "$BACKUP_DIR"
    fi
    if [ -d "$COMFYUI_DIR/web" ]; then
        rm -rf "$COMFYUI_DIR/web"
    fi
    if [ -d "$COMFYUI_DIR/user" ]; then
        rm -rf "$COMFYUI_DIR/user"
    fi
    if [ -d "$COMFYUI_DIR/output" ]; then
        rm -rf "$COMFYUI_DIR/output"
    fi
    if [ -d "$COMFYUI_DIR/models" ]; then
        rm -rf "$COMFYUI_DIR/models"
    fi
    if [ -d "$COMFYUI_DIR/input" ]; then
        rm -rf "$COMFYUI_DIR/input"
    fi
    if [ -d "$COMFYUI_DIR/custom_nodes" ]; then
        rm -rf "$COMFYUI_DIR/custom_nodes"
    fi
    ln -sf "$BACKUP_DIR/web" "$COMFYUI_DIR"
    ln -sf "$BACKUP_DIR/user" "$COMFYUI_DIR"
    ln -sf "$BACKUP_DIR/output" "$COMFYUI_DIR"
    ln -sf "$BACKUP_DIR/models" "$COMFYUI_DIR"
    ln -sf "$BACKUP_DIR/input" "$COMFYUI_DIR"
    ln -sf "$BACKUP_DIR/custom_nodes" "$COMFYUI_DIR"
    printf "[*] [\033[0;32mLinked\033[m] [%s/web]\n" "$COMFYUI_DIR"
    printf "[*] [\033[0;32mTo:\033[m] [%s]\n" "$BACKUP_DIR/web"
    printf "[*] [\033[0;32mLinked\033[m] [%s/user]\n" "$COMFYUI_DIR"
    printf "[*] [\033[0;32mTo:\033[m] [%s]\n" "$BACKUP_DIR/user"
    printf "[*] [\033[0;32mLinked\033[m] [%s/output]\n" "$COMFYUI_DIR"
    printf "[*] [\033[0;32mTo:\033[m] [%s]\n" "$BACKUP_DIR/output"
    printf "[*] [\033[0;32mLinked\033[m] [%s/models]\n" "$COMFYUI_DIR"
    printf "[*] [\033[0;32mTo:\033[m] [%s]\n" "$BACKUP_DIR/models"
    printf "[*] [\033[0;32mLinked\033[m] [%s/input]\n" "$COMFYUI_DIR"
    printf "[*] [\033[0;32mTo:\033[m] [%s]\n" "$BACKUP_DIR/input"
    printf "[*] [\033[0;32mLinked\033[m] [%s/custom_nodes]\n" "$COMFYUI_DIR"
    printf "[*] [\033[0;32mTo:\033[m] [%s]\n" "$BACKUP_DIR/custom_nodes"
}

INST_DEPS
INSTALL_COMFYUI
LINKING_DIRS
INSTALL_COMFYUI_MANAGER
INSTALL_COMFYUI_MINI

chmod +x "$COMFYUI_INSTALLER_DIR/scripts/"*.sh
chmod +x "$COMFYUI_DIR/custom_nodes/ComfyUIMini/scripts/"*.sh

printf "\033[32mFinished!\033[0m\n\n"
printf "\033[32mTo Launch ComfyUI manually, use: 'scripts/run_gpu.sh' or 'scripts/run_cpu.sh' \033[0m\n"
printf "\033[32mTo Launch ComfyUIMini manually, use: 'ComfyUI/custom_nodes/ComfyUIMini/scripts/start.sh' \033[0m\n\n"

printf "\033[32mTo Launch ComfyUI as systemd service, run: 'sudo systemctl start ComfyUI.service' \033[0m\n"
printf "\033[32mTo Launch ComfyUIMini as systemd service, run: 'sudo systemctl start ComfyUIMini.service' \033[0m\n\n"

printf "\033[32mTo enable ComfyUI service at boot, run: 'sudo systemctl enable ComfyUI.service' \033[0m\n"
printf "\033[32mTo enable ComfyUIMini service at boot, run: 'sudo systemctl enable ComfyUIMini.service' \033[0m\n\n"

printf "\033[32mTo view the logs of ComfyUI, run: 'multitail -f ComfyUI/user/comfyui.log' \033[0m\n\n"
printf "\033[32mTo view the logs of ComfyUI, run: 'journalctl -f -u ComfyUI.service' \033[0m\n"

printf "\033[32mTo view the logs of ComfyUIMini, run: 'journalctl -f -u ComfyUIMini.service' \033[0m\n\n"

printf "\033[32mOpen a browser and go to: 'http://0.0.0.0:8188' for ComfyUI \033[0m\n"
printf "\033[32mOpen a browser and go to: 'http://0.0.0.0:3000' for ComfyUIMini \033[0m\n"

# xdg-open http://0.0.0.0:3000
# xdg-open http://0.0.0.0:8188
multitail -f "$COMFYUI_DIR/user/comfyui.log"
