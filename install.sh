#!/usr/bin/env bash
if [ "$1" == "--amd" ]; then
    printf "[!] [\033[0;32mAMD\033[m].\n"
    GPU="amd"
fi
if [ "$1" == "--nvidia" ]; then
    printf "[!] [\033[0;32mNvidia\033[m].\n"
    GPU="nvidia"
fi
if [ -z "$1" ]; then
    printf "[!] Please specify the GPU you want to use. Use --amd or --nvidia.\n"
    exit 1
fi
if [ ! -f .settings ]; then
    cat <<EOF >.settings
export COMFYUI_INSTALLER_DIR="$PWD"
export BACKUP_DIR="/media/$USER/DATA/ai-stuff"
export COMFYUI_DIR="$PWD/ComfyUI"
export VIRTUAL_ENV="$PWD/ComfyUI/venv"
export COMFYUI_SERVICE="$PWD/scripts/ComfyUI.service"
export COMFYUI_MINI_SERVICE="$PWD/scripts/ComfyUIMini.service"
EOF
    source .settings
else
    source .settings
fi

# Install - Nvidia
# set -e
printf "[*] Installing for [\033[0;32mNvidia\033[m],\n"
# source ./python-version.sh
# ACTIVATE_VENV() {
#     cd "$COMFYUI_INSTALLER_DIR/ComfyUI" || exit 1
#     python -m venv "$VIRTUAL_ENV"
#     source "$VIRTUAL_ENV"/bin/activate
# }
INSTALL_COMFYUI() {
    if [ -d "$COMFYUI_DIR" ]; then
        printf "[!] [\033[0;32mComfyUI\033[m] already exists, updating.\n"
        git pull
    else
        printf "[*] Installing [\033[0;32mComfyUI\033[m] and [\033[0;32mComfyUI-Manager\033[m]\n"
        # wget https://github.com/ltdrdata/ComfyUI-Manager/raw/main/scripts/install-comfyui-venv-linux.sh
        # wget -O - https://github.com/ltdrdata/ComfyUI-Manager/raw/main/scripts/install-comfyui-venv-linux.sh | bash
        # bash <(curl -Ls https://github.com/ltdrdata/ComfyUI-Manager/raw/main/scripts/install-comfyui-venv-linux.sh)
        chmod +x scripts/*.sh
        if [ "$GPU" == "nvidia" ]; then
            printf "[*] Installing [\033[0;32mComfyUI\033[m] for [\033[0;32mNvidia\033[m]\n"
            ./install-comfyui-nvidia-venv-linux.sh >/dev/null 2>&1
        elif [ "$GPU" == "amd" ]; then
            printf "[*] Installing [\033[0;32mComfyUI\033[m] for [\033[0;32mAMD\033[m]\n"
            ./install-comfyui-amd-venv-linux.sh >/dev/null 2>&1
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
# INSTALL_REQUIREMENTS() {
#     ACTIVATE_VENV
#     find "$COMFYUI_DIR/" -name "requirements.txt" -exec printf "[*] Installing: [\033[0;32m%s\033[m]\n" {} \; -exec pip install -q -r {} \;
#     find "$COMFYUI_DIR/custom_nodes/" -name "requirements.txt" -exec printf "[*] Installing: [\033[0;32m%s\033[m]\n" {} \; -exec pip install -q -r {} \;

#     pip uninstall -q -y opencv-contrib-python
#     pip install -q opencv-contrib-python
# }
CREATE_SERVICES() {
    printf "[*] Creating [\033[0;32mComfyUI.service\033[m] file.\n"
    cat <<EOF >"$COMFYUI_SERVICE"
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
    printf "[*] [\033[0;32mComfyUI.service\033[m] file created, now adding to systemd.\n"
    sudo cp "$COMFYUI_SERVICE" /etc/systemd/system/

    printf "[*] Creating [\033[0;32mComfyUIMini.service\033[m] file.\n"
    cat <<EOF >"$COMFYUI_MINI_SERVICE"
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
    printf "[*] [\033[0;32mComfyUIMini.service\033[m] file created, now adding to systemd.\n"
    sudo cp "$COMFYUI_MINI_SERVICE" /etc/systemd/system/

    sudo systemctl daemon-reload
}

INSTALL_COMFYUI
LINKING_DIRS
# INSTALL_REQUIREMENTS
CREATE_SERVICES

chmod +x "$COMFYUI_INSTALLER_DIR/scripts/"*.sh
chmod +x "$COMFYUI_INSTALLER_DIR/ComfyUIMini/scripts/"*.sh

printf "\033[32mFinished!\033[0m\n\n"
printf "\033[32mTo Launch ComfyUI manually, use: 'scripts/run_gpu.sh' or 'scripts/run_cpu.sh' \033[0m\n"
printf "\033[32mTo launch ComfyUIMini manually, use: 'ComfyUI/custom_nodes/ComfyUIMini/scripts/start.sh' \033[0m\n\n"
printf "\033[32mTo start ComfyUI as systemd service, run: 'sudo systemctl start ComfyUI.service' \033[0m\n"
printf "\033[32mTo start ComfyUIMini as systemd service, run: 'sudo systemctl start ComfyUIMini.service' \033[0m\n\n"
printf "\033[32mTo enable ComfyUI service at boot, run: 'sudo systemctl enable ComfyUI.service' \033[0m\n"
printf "\033[32mTo enable ComfyUIMini service at boot, run: 'sudo systemctl enable ComfyUIMini.service' \033[0m\n\n"
printf "\033[32mTo view the logs of ComfyUI, run: 'tail -f ComfyUI/user/comfyui.log' \033[0m\n"
printf "\033[32mTo view the logs of ComfyUI, run: 'multitail -f ComfyUI/user/comfyui.log' \033[0m\n\n"
printf "\033[32mTo view the logs of ComfyUI, run: 'sudo journalctl -f -u ComfyUI.service' \033[0m\n"
printf "\033[32mTo view the logs of ComfyUIMini, run: 'sudo journalctl -f -u ComfyUIMini.service' \033[0m\n\n"

sudo systemctl start ComfyUI.service
sudo systemctl start ComfyUIMini.service
printf "\033[32mOpen a browser and go to: 'http://0.0.0.0:8188' for ComfyUI \033[0m\n"
printf "\033[32mOpen a browser and go to: 'http://0.0.0.0:3000' for ComfyUIMini \033[0m\n"

xdg-open http://0.0.0.0:3000
xdg-open http://0.0.0.0:8188
sudo journalctl -f -u ComfyUI.service
# if command -v multitail 2>&1 >/dev/null; then
#     multitail -f "$COMFYUI_INSTALLER_DIR/ComfyUI/user/comfyui.log"
# elif command -v tail 2>&1 >/dev/null; then
#     tail -f "$COMFYUI_INSTALLER_DIR/ComfyUI/user/comfyui.log"
# else
#     sudo journalctl -f -u ComfyUI.service
#     sudo journalctl -f -u ComfyUIMini.service
# fi
