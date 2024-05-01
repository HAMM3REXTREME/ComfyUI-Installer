#!/bin/sh
# ComfyUI-Installer main install script.

# pip packages depend on your GPU vendor. You might want to try using an updated or nightly version here if ComfyUI is not working for you. 
readonly pip_amd="torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.0"
readonly pip_nvidia="torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121"

readonly comfyui_repo="https://github.com/comfyanonymous/ComfyUI.git" # ComfyUI GitHub repository
readonly comfyui_folder_name="ComfyUI" # ComfyUI repository folder name



printf "Make sure you have all the GPU packages needed along with git, python and pip.\n"



# Installer - does the actual installing
main_install () {
    printf "\033[0;33mInfo:\033[m Cloning ComfyUI git repo...\n"
    git clone "$comfyui_repo" "$comfyui_folder_name"
    cd "$comfyui_folder_name" || exit

    printf "\033[0;33mInfo:\033[m Setting up a Python venv...\n"
    python -m venv comfy-venv
    source comfy-venv/bin/activate
    printf "\033[0;33mInfo:\033[m Installing dependencies in python venv...\n"
    pip install "$1"
    pip install -r requirements.txt

    # Copy launch script inside ComfyUI-Installer/ComfyUI/ComfyUI
    cp ../launch.sh ComfyUI
    chmod +x ComfyUI
    printf "Launch using './ComfyUI' inside the $comfyui_folder_name folder.\n"

    printf "Install a checkpoint inside $comfyui_folder_name/models/checkpoints/ to get started.\n"
    
    cd ..

}

menu_icon () {
    # Make paths match our clone location
    folder_path="$PWD/$comfyui_folder_name" # ComfyUI folder
    exec_path="$PWD/$comfyui_folder_name/ComfyUI" # Exec
    icon_path="$PWD/pictures/comfyui.svg" # ComfyUI Icon

    desktop-file-install --dir="$HOME/.local/share/applications/" --set-key=Path --set-value="$folder_path" --set-key=Exec --set-value="$exec_path" --set-icon="$icon_path" ComfyUI.desktop
}



# Pre-install checks
if ! command -v git python pip >/dev/null 2>&1
then
    printf "\033[0;31mError:\033[0m Please install git, python and pip in order to continue.\n Also make sure you have the correct GPU specific packages installed.\n"
    exit
fi

# GPU vendor selection
if [ "$1" = "--amd" ]
then
    printf "\033[0;33mInfo:\033[m Installing for \033[0;31mAMD\033[m GPU...\n"
    printf "if you have a RDNA2 or 3 card, you might want to check the README.\n"
    main_install $amd_gpu_repo
elif [ "$1" = "--nvidia" ]
then
    printf "\033[0;33mInfo:\033[m Installing for \033[0;32mNvidia\033[m GPU...\n"
    main_install $nvidia_gpu_repo
else
    printf "\033[0;31mError:\033[m Please specify if you want to install for AMD or Nvidia GPU.\n"
    printf "    - Use either \033[0;31m--amd\033[m or \033[0;32m--nvidia\033[m as an argument.\n"
    printf "    - You can also specify --make-menu-entry after your GPU vendor to make a menu entry for ComfyUI.\n"
    exit
fi

# Make a desktop entry if the user asked for it.
if [ "$2" = "--make-menu-entry" ]
then
    printf "\033[0;33mInfo:\033[m Making a menu entry for ComfyUI...\n"
    menu_icon
fi

printf "\n\033[0;33mInfo:\033[m Script Exited\n"
