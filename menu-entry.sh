#!/usr/bin/env bash
# Make a menu entry
exec_path="$PWD/launch.sh" # Launch script
icon_path="$PWD/pictures/comfyui.svg" # ComfyUI Icon
desktop-file-install --dir="$HOME/.local/share/applications/" --set-key=Path --set-value="$PWD" --set-key=Exec --set-value="$exec_path" --set-icon="$icon_path" ComfyUI.desktop