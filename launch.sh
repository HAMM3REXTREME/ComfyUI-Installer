#!/bin/sh
# ComfyUI-Installer, launcher script.

args=$@ # User passed command line args
source venv/bin/activate
cd ComfyUI

# Add any env vars or custom args below
HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py $args
