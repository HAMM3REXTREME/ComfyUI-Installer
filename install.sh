#!/bin/sh



# Pip packages depend on GPU vendor. You might want to try using an updated or nightly version here if ComfyUI is not working for you. 
readonly pip_amd="torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/rocm5.6"
readonly pip_nvidia="torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121 xformers"
readonly comfyui_repo="https://github.com/comfyanonymous/ComfyUI.git"

printf "This script will install ComfyUI. Tested on Arch + AMD GPU.\n"
printf "Make sure you have all the GPU packages needed along with git, python and pip.\n"




# Installer
main_install () {
    printf "Cloning ComfyUI git repo...\n"
    git clone "$comfyui_repo"
    cd ComfyUI || exit

    printf "Setting up a Python venv...\n"
    python -m venv comfy-venv
    source comfy-venv/bin/activate
    printf "Installing dependencies in python venv...\n"
    pip install "$1"
    pip install -r requirements.txt

    cp ../launch.sh ComfyUI
    chmod +x ComfyUI
    printf "Launch using './ComfyUI' inside the 'ComfyUI' folder.\n"

    printf "Install a checkpoint inside ComfyUI/models/checkpoints/ to get started.\n"

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
    exit
fi

printf "\n*Script Exited*\n"
