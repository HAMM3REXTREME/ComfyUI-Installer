#!/usr/bin/env bash
if [ -n "$COMFYUI_INSTALLER_DIR" ]; then
    if [ ! -f ../.settings ]; then
        printf "[!] Please run install.sh first!\n"
    else
        source ../.settings
    fi
fi

# Make a menu entry
exec_path="$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"   # Launch script
icon_path="$COMFYUI_INSTALLER_DIR/graphics/comfyui.svg" # ComfyUI Icon
desktop-file-install \
    --dir="$HOME/.local/share/applications/" \
    --set-key=Path \
    --set-value="$PWD" \
    --set-key=Exec \
    --set-value="$exec_path" \
    --set-icon="$icon_path" \
    "$COMFYUI_INSTALLER_DIR/scripts/ComfyUI.desktop"
