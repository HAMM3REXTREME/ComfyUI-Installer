#!/usr/bin/env bash
set -e
if [ -n "$COMFYUI_INSTALLER_DIR" ]; then
    if [ -f ".settings" ]; then
        source .settings
    elif [ -f "scripts/.settings" ]; then
        source scripts/.settings
    else
        printf "[!] No settings file found. Please run the setup script first."
        exit 1
    fi
fi

SYSTEMD_MENU_SELECTION=$(whiptail --title "Menu example" --menu "Choose an option" $LINES $COLUMNS $((LINES - 8)) \
    "Create ComfyUI Service" "Create a systemd service for ComfyUI" \
    "Start ComfyUI Service" "Start the ComfyUI systemd service" \
    "Stop ComfyUI Service" "Stop the ComfyUI systemd service" \
    "Restart ComfyUI Service" "Restart the ComfyUI systemd service" \
    "Enable ComfyUI Service" "Enable the ComfyUI systemd service" \
    "Show ComfyUI Service Status" "Show the status of the ComfyUI systemd service" \
    "Remove ComfyUI Service" "Remove the ComfyUI systemd service" \
    "Exit" "Exit" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus == 0 ]; then
    case $SYSTEMD_MENU_SELECTION in
    "Create ComfyUI Service")
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
        sudo systemctl daemon-reload
        printf "[*] Created [\033[0;32mComfyUI.service\033[m] file.\n"
        ;;
    "Start ComfyUI Service")
        printf "[*] Starting [\033[0;32mComfyUI.service\033[m] service.\n"
        sudo systemctl start ComfyUI.service
        printf "[*] Started [\033[0;32mComfyUI.service\033[m] service.\n"
        ;;
    "Stop ComfyUI Service")
        printf "[*] Stopping [\033[0;32mComfyUI.service\033[m] service.\n"
        sudo systemctl stop ComfyUI.service
        printf "[*] Stopped [\033[0;32mComfyUI.service\033[m] service.\n"
        ;;
    "Restart ComfyUI Service")
        printf "[*] Restarting [\033[0;32mComfyUI.service\033[m] service.\n"
        sudo systemctl restart ComfyUI.service
        printf "[*] Restarted [\033[0;32mComfyUI.service\033[m] service.\n"
        ;;
    "Enable ComfyUI Service")
        printf "[*] Enabling [\033[0;32mComfyUI.service\033[m] service.\n"
        sudo systemctl enable ComfyUI.service
        printf "[*] Enabled [\033[0;32mComfyUI.service\033[m] service.\n"
        ;;
    "Show ComfyUI Service Status")
        printf "[*] Showing [\033[0;32mComfyUI.service\033[m] service status.\n"
        sudo systemctl status ComfyUI.service
        printf "[*] Shown [\033[0;32mComfyUI.service\033[m] service status.\n"
        ;;
    "Remove ComfyUI Service")
        printf "[*] Removing [\033[0;32mComfyUI.service\033[m] service.\n"
        sudo systemctl stop ComfyUI.service
        sudo systemctl disable ComfyUI.service
        sudo rm /etc/systemd/system/ComfyUI.service
        sudo systemctl daemon-reload
        printf "[*] Removed [\033[0;32mComfyUI.service\033[m] service.\n"
        ;;
    "Exit")
        exit 1
        ;;
    *)
        printf "[!] Invalid option.\n"
        ;;

    esac
else
    printf "[!] User selected Cancel."
    exit 1
fi
