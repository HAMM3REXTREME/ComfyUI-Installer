#!/bin/sh



# Repos
readonly amd_gpu_repo="https://download.pytorch.org/whl/rocm5.4.2"
readonly nvidia_gpu_repo="https://download.pytorch.org/whl/cu118xformers"
readonly comfyui_main_repo="https://github.com/comfyanonymous/ComfyUI.git"

printf "This script will install ComfyUI. Tested on Arch + AMD GPU.\n"
printf "Make sure you have all the GPU packages needed along with git, python and pip.\n"




# Installer
main_install () {
    printf "Cloning ComfyUI git repo...\n"
    git clone "$comfyui_main_repo"
    cd ComfyUI || exit

    printf "Setting up a Python venv...\n"
    python -m venv sdg
    source sdg/bin/activate
    printf "Installing dependencies in python venv...\n"
    pip install torch torchvision torchaudio --extra-index-url "$1"
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
