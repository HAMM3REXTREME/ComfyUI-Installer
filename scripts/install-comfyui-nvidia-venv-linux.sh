#!/usr/bin/env bash
set -e
if [ -n "$COMFYUI_INSTALLER_DIR" ]; then
    if [ ! -f ../.settings ]; then
        printf "[!] Please run install.sh first!\n"
    else
        source ../.settings
    fi
fi
if [ -d "$COMFYUI_INSTALLER_DIR/ComfyUI" ]; then
    printf "[!] [\033[0;32mComfyUI\033[m] already exists, updating.\n"
    cd "$COMFYUI_INSTALLER_DIR"/ComfyUI || exit 1
    git pull
else
    printf "[*] Installing [\033[0;32mComfyUI\033[m] and [\033[0;32mComfyUI-Manager\033[m]\n"
    cd "$COMFYUI_INSTALLER_DIR" || exit 1
    git clone https://github.com/comfyanonymous/ComfyUI
fi

if [ -d "$COMFYUI_INSTALLER_DIR/custom_nodes/comfyui-manager" ]; then
    printf "[!] [\033[0;32mComfyUI-Manager\033[m] already exists, updating.\n"
    cd "$COMFYUI_INSTALLER_DIR"/custom_nodes/comfyui-manager || exit 1
    git pull
else
    printf "[*] Installing [\033[0;32mComfyUI-Manager\033[m]\n"
    cd "$COMFYUI_DIR"/custom_nodes || exit 1
    git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager
fi

if [ -d "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini" ]; then
    printf "[!] [\033[0;32mComfyUIMini\033[m] already exists, updating.\n"
    cd "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini" || exit 1
    chmod +x ./scripts/update.sh
    ./scripts/update.sh
else
    printf "[*] Cloning [\033[0;32mComfyUIMini\033[m]\n"
    git clone https://github.com/ImDarkTom/ComfyUIMini "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini" >/dev/null 2>&1
    cd "$COMFYUI_INSTALLER_DIR/ComfyUI/custom_nodes/ComfyUIMini" || exit 1
    chmod +x ./scripts/*.sh
    if ! command -v npm &>/dev/null; then
        printf "[!] [\033[0;32mNPM\033[m] is not installed. Please install NPM and Node.js and try again.\n"
        exit 1
    fi

    printf "[*] Installing dependencies for ComfyUIMini\n"
    npm install
    if [ $? -ne 0 ]; then
        printf "[!] Failed to update dependencies. Please check your internet connection and try again.\n"
        exit 1
    fi

    printf "[*] Building ComfyUIMini\n"
    npm run build
    if [ $? -ne 0 ]; then
        printf "[!] Build failed. Check the console for more information.\n"
        exit 1
    fi
    cp ./config/default.example.json ./config/default.json
    sed -i "s|path/to/comfyui/output/folder|$COMFYUI_DIR/output|g" ./config/default.json
    rm -rf workflows
    ln -s "$COMFYUI_DIR/user/default/workflows" workflows
fi

cd "$COMFYUI_INSTALLER_DIR"/ComfyUI || exit 1
python -m venv venv
source venv/bin/activate

python -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu128
# You might want to try using a newer or nightly version here if ComfyUI is not working for you.
python -m pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128
python -m pip install -r requirements.txt
python -m pip install -r custom_nodes/comfyui-manager/requirements.txt

find custom_nodes/ -type f -name 'requirements.txt' -exec pip install -r {} \;

pip install deepdiff pattern tensorflow xformers PyOpenGL-accelerate

cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_gpu.sh"
#!/bin/bash
cd "$COMFYUI_DIR" || exit 1
source venv/bin/activate
python main.py --listen 0.0.0.0 --preview-method auto
EOF

cat <<EOF >"$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
#!/bin/bash" >"$COMFYUI_INSTALLER_DIR/scripts/run_cpu.sh"
cd $COMFYUI_DIR
source venv/bin/activate
python main.py --listen 0.0.0.0 --preview-method auto --cpu
EOF
