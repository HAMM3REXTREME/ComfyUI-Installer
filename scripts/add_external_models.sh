#!/usr/bin/env bash
set -e

if [ -n "$COMFYUI_INSTALLER_DIR" ]; then
    if [ -f ".settings" ]; then
        pirntf "source [\033[0;32m.settings\033[m]"
        source .settings
    elif [ -f "scripts/.settings" ]; then
        printf "source [\033[0;32mscripts/.settings\033[m]"
        source scripts/.settings
    else
        printf "[!] No settings file found. Please run the setup script first."
        exit 1
    fi
fi

EXTRA_MODELS() {
    EXTERNAL_MODELS_DIR=$(whiptail --title "External Models Directory." --inputbox "Where should external models be stored/located? (Default: $PWD/backups/models)" $LINES $COLUMNS "$PWD/backup/models" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus == 0 ]; then
        printf "[*] [\033[0;32mExternal Models\033[m] directory: [\033[0;32m%s\033[m]\n" "$EXTERNAL_MODELS_DIR"
        if [ ! -d "$EXTERNAL_MODELS_DIR" ]; then
            printf "[!] [\033[0;32mExternal Models\033[m] directory not found, creating.\n"
            mkdir -p "$EXTERNAL_MODELS_DIR"
        fi
        if [ -f "$COMFYUI_DIR/extra_model_paths.yaml" ]; then
            printf "[!] [\033[0;32mExtra Model Paths\033[m] file found, creating backup.\n"
            cp "$COMFYUI_DIR/extra_model_paths.yaml" "$COMFYUI_DIR/extra_model_paths.yaml.bak"
        fi
        cat <<EOF >>"$COMFYUI_DIR/extra_model_paths.yaml"
comfyui:
    base_path: $EXTERNAL_MODELS_DIR
    # You can use is_default to mark that these folders should be listed first, and used as the default dirs for eg downloads
    is_default: true
    checkpoints: models/checkpoints/
    clip: models/clip/
    clip_vision: models/clip_vision/
    configs: models/configs/
    controlnet: models/controlnet/
    diffusion_models: |
    models/diffusion_models
    lora: models/lora/
    upscale_models: models/upscale_models/
    vae: models/vae/
EOF
    else
        printf "[!] User selected Cancel."
        exit 1
    fi

}

EXTRA_MODELS
