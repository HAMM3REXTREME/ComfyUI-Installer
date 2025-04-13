#!/usr/bin/env bash
# Install - AMD
set -e
printf "Installing for \033[0;31mAMD\033[m, "
source ./python-version.sh

git clone https://github.com/comfyanonymous/ComfyUI.git

printf "Setting up and installing dependencies for \033[0;31mAMD\033[m inside venv.\n"
python -m venv venv
source venv/bin/activate

# You might want to try using a newer or nightly version here if ComfyUI is not working for you.
# pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.3
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2.4
pip install -r ComfyUI/requirements.txt

printf "\033[32mFinished: Launch using 'launch.sh' script, or make a menu entry.\033[0m\n"
