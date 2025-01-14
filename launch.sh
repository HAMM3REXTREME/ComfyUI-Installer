#!/usr/bin/env bash
# ComfyUI-Installer launcher script.
set -e
args=$@ # Command line arguments passed by the user
source venv/bin/activate # venv would have the correct python version
cd ComfyUI

# Add any environment variables or custom arguments below. For example:
# HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py --lowvram --preview-method auto --use-split-cross-attention $args
python main.py $args
