#!/bin/sh



# Pip packages depend on GPU vendor. You might want to try using an updated or nightly version here if ComfyUI is not working for you. 
readonly pip_amd="torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6"
readonly pip_nvidia="torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121 xformers"

readonly comfyui_repo="https://github.com/comfyanonymous/ComfyUI.git" # ComfyUI GitHub Repo
readonly comfyui_folder_name="ComfyUI" # Folder in which to clone ComfyUI Repo


printf "This script will install ComfyUI. Tested on Arch + AMD GPU.\n"
printf "Make sure you have all the GPU packages needed along with git, python and pip.\n"




# Installer
main_install () {
    printf "Cloning ComfyUI git repo...\n"
    git clone "$comfyui_repo" "$comfyui_folder_name"
    cd "$comfyui_folder_name" || exit

    printf "Setting up a Python venv...\n"
    python -m venv comfy-venv
    source comfy-venv/bin/activate
    printf "Installing dependencies in python venv...\n"
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
    folder_path="$PWD/$comfyui_folder_name" # ComfyUI folder
    exec_path="$PWD/$comfyui_folder_name/ComfyUI" # Exec
    icon_path="$PWD/pictures/comfyui.svg" # ComfyUI Icon

    desktop-file-install --dir="$HOME/.local/share/applications/" --set-key=Path --set-value="$folder_path" --set-key=Exec --set-value="$exec_path" --set-icon="$icon_path" ComfyUI.desktop
}



# Pre-install checks
if ! command -v git python pip >/dev/null 2>&1
then
    printf "\033[0;31mError:\033[0m Please install git, python and pip in order to continue.\n"
    exit
fi

# GPU Vendors
if [ "$1" = "--amd" ]
then
    printf "Installing for AMD GPU.\n"
    printf "if you have a RDNA2 or 3 card, check README.\n"
    main_install $amd_gpu_repo
elif [ "$1" = "--nvidia" ]
then
    printf "Installing for Nvidia GPU.\n"
    main_install $nvidia_gpu_repo
else
    printf "\033[0;31mError:\033[0m Please specify if you want to install for AMD or Nvidia GPU.\n"
    printf "Use either --amd or --nvidia as an argument.\n"
    printf "You can also specify --make-menu-entry after your GPU vendor to make a menu entry for ComfyUI.\n"
    exit
fi

if [ "$2" = "--make-menu-entry" ]
then
    printf "Making a menu entry for ComfyUI...\n"
    menu_icon
fi

printf "\n*Script Exited*\n"
