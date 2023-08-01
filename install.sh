#!/bin/sh

amd_gpu_repo="https://download.pytorch.org/whl/rocm5.4.2"
nvidia_gpu_repo="https://download.pytorch.org/whl/cu118xformers"


printf "This script will install ComfyUI. Tested on Arch + AMD GPU.\n"
printf "Make sure you have all the GPU packages needed along with git, python and pip.\n"






# Installer
text_install () {
    printf "Cloning ComfyUI git repo...\n"
    git clone https://github.com/comfyanonymous/ComfyUI.git
    cd ComfyUI || exit

    printf "Now setting a Python virtualenv...\n"
    python -m venv sdg
    source sdg/bin/activate

    printf "Installing dependencies in python venv...\n"
    pip install torch torchvision torchaudio --extra-index-url "$1"
    pip install -r requirements.txt

    printf "Now copying launch script...\n"
    cp ../launch.sh launch.sh
    chmod +x launch.sh
    printf "Use this to easily launch ComfyUI.\n"

    printf "Now install a checkpoint inside models/checkpoints/ to get started.\n"

}

# Pre-install checks

if ! command -v git python pip >/dev/null 2>&1
then
    printf "\033[0;31mError:\033[0m Please install git, python and pip in order to continue.\n"
    exit
fi


if [ "$1" = "--amd" ]
then
    printf "Set to AMD GPU.\n"
    printf "if you have a RDNA2 or 3 card, check README.\n"
    text_install $amd_gpu_repo
elif [ "$1" = "--nvidia" ]
then
    printf "Set to Nvidia GPU.\n"
    text_install $nvidia_gpu_repo
else
    printf "\033[0;31mError:\033[0m Please specify if you want to install for AMD or Nvidia GPU.\n"
    printf "Use either --amd or --nvidia as an argument.\n"
    exit
fi
