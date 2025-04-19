#!/usr/bin/env bash
# set -e
COMFYUI_INSTALLER_DIR=$PWD
COMFYUI_DIR=$PWD/ComfyUI
VIRTUAL_ENV=$PWD/venv

ASK_USER_INPUT() {
    eval "$(resize)"
    COMFYUI_INSTALLER_DIR=$(whiptail --title "Installer directory." --inputbox "Enter the directory where the installer currently is located. (Default: $COMFYUI_INSTALLER_DIR)" $LINES $COLUMNS "$PWD" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] [\033[0;32mInstaller\033[m] directory: [\033[0;32m%s\033[m]\n" "$COMFYUI_INSTALLER_DIR"
    else
        printf "[!] User selected Cancel."
        exit 1
    fi

    VIRTUAL_ENV=$(whiptail --title "Virtual Environment Directory." --inputbox "Where should the virtual environment directory be created? (Default: $VIRTUAL_ENV)" $LINES $COLUMNS "$PWD/venv" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] [\033[0;32mVirtual Environment\033[m] directory: [\033[0;32m%s\033[m]\n" "$VIRTUAL_ENV"
    else
        printf "[!] User selected Cancel."
        exit 1
    fi

    COMFYUI_DIR=$(whiptail --title "ComfyUI Directory." --inputbox "Where should ComfyUI be installed? (Default: $PWD/ComfyUI)" $LINES $COLUMNS "$COMFYUI_DIR" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] [\033[0;32mComfyUI\033[m] directory: [\033[0;32m%s\033[m]\n" "$COMFYUI_DIR"
    else
        printf "[!] User selected Cancel."
        exit 1
    fi

    cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/.settings"
# The directory where the installer is located:
export COMFYUI_INSTALLER_DIR=$COMFYUI_INSTALLER_DIR
# The virtual environment directory:
export VIRTUAL_ENV=$VIRTUAL_ENV
# The directory where the ComfyUI is located:
export COMFYUI_DIR=$COMFYUI_DIR

EOF
    printf "[*] Created [\033[0;32m.settings\033[m] file with the following contents:\n\n"
    cat "$COMFYUI_INSTALLER_DIR/scripts/.settings"
}

if [ ! -f "$COMFYUI_INSTALLER_DIR/scripts/.settings" ]; then
    printf "[*] [\033[0;32m.settings\033[m] file not found, creating.\n"
    ASK_USER_INPUT
    printf "[*] Created [\033[0;32m.settings\033[m] file.\n"
    source "$COMFYUI_INSTALLER_DIR/scripts/.settings"
    sleep 1
else
    printf "[*] [\033[0;32m.settings\033[m] file found, loading.\n"
    source "$COMFYUI_INSTALLER_DIR/scripts/.settings"
    sleep 1
fi

MAIN_MENU_SELECTION=$(whiptail --title "Menu example" --menu "Choose an option" $LINES $COLUMNS $((LINES - 8)) \
    "Install ComfyUI" "Install/Update ComfyUI" \
    "Add External Models" "Add external models directory to ComfyUI" \
    "Lauch ComfyUI Gpu" "Launch ComfyUI with GPU (in console)" \
    "Lauch ComfyUI Cpu" "Launch ComfyUI with CPU (in console)" \
    "Manage Systemd Services" "Manage systemd services" \
    "Show log" "Show the log of ComfyUI" \
    "Exit" "Exit" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus == 0 ]; then
    case $MAIN_MENU_SELECTION in
    "Install ComfyUI")
        "$COMFYUI_INSTALLER_DIR/scripts/install_comfyui.sh"
        ;;
    "Add External Models")
        "$COMFYUI_INSTALLER_DIR/scripts/add_external_models.sh"
        ;;
    "Lauch ComfyUI Gpu")
        "$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"
        ;;
    "Lauch ComfyUI Cpu")
        "$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
        ;;
    "Manage Systemd Services")
        "$COMFYUI_INSTALLER_DIR/scripts/manage_systemd.sh"
        ;;
    "Show log")
        tail -f "$COMFYUI_DIR/user/comfyui.log"
        ;;
    "Exit")
        exit
        ;;
    *)
        printf "[!] Invalid option.\n"
        ;;
    esac
else
    printf "[!] User selected Cancel."
    exit 1
fi

chmod +x "$COMFYUI_INSTALLER_DIR/scripts/"*.sh

printf "\033[32mFinished!\033[0m\n\n"
printf "\033[32mTo Launch ComfyUI manually, use: 'scripts/run_gpu.sh' or 'scripts/run_cpu.sh' \033[0m\n"

printf "\033[32mOpen a browser and go to: 'http://0.0.0.0:8188' for ComfyUI \033[0m\n"

./scripts/run_gpu.sh

# xdg-open http://0.0.0.0:8188
tail -f "$COMFYUI_DIR/user/comfyui.log"
