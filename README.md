# ComfyUI Installer

Easily install ComfyUI (in a python venv) on Linux.
Tested on Arch + AMD GPU.

![ComfyUI Screenshot](pictures/comfyui_screenshot.png)

# Quick Start

Make sure to install for your GPU Vendor (AMD/Nvidia):

```
git clone https://github.com/HAMM3REXTREME/ComfyUI-Installer
cd ComfyUI-Installer
./install.sh --amd/nvidia --make-menu-entry # AMD or Nvidia, along with optional menu entry
cd ComfyUI

./ComfyUI # Launch
```

# Installation

1. To install ComfyUI using this script, **clone this repo and cd into it**:  
   `git clone https://github.com/HAMM3REXTREME/ComfyUI-Installer && cd ComfyUI-Installer`

2. After that is completed, install for either AMD or Nvidia.  
   **To install for AMD:** `./install.sh --amd`  
   **To install for Nvidia:** `./install.sh --nvidia`  
   _Tip:_ You can optionally add `--make-menu-entry` after your GPU vendor in order to make a desktop entry.

3. Almost done! You can now get your models and put them in their proper directories:  
   Put your SD checkpoints (the huge ckpt/safetensors files) in: `ComfyUI/models/checkpoints`  
   Put your VAE in: `ComfyUI/models/vae`

Once that is done, **launch comfyUI using**: `cd ComfyUI && ./ComfyUI`

# Updating

### Updating ComfyUI

Simply cd into the ComfyUI folder and run git pull:  
`cd ComfyUI && git pull`

### Upgrading python venv packages


**Make sure to check out the actual [ComfyUI repo](https://github.com/comfyanonymous/ComfyUI) for the most up to date information.**

1. While in the ComfyUI folder, run `source comfy-venv/bin/activate` in order to access the python venv.  
   (The installer creates the python venv inside the ComfyUI folder by default.)

2. Upgrade torch, use the command for your GPU vendor (similar to the installer script):  
   **For AMD:** `pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.7`  
   **For Nvidia:** `pip install --upgrade torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121`  
   _Some numbers might get updated as things get newer versions_

3. Upgrade ComfyUI dependencies by running this command (inside the ComfyUI folder):  
   `pip install --upgrade -r requirements.txt`

After this you should have everything installed and can proceed to running ComfyUI.

# Troubleshooting

If you get the "Torch not compiled with CUDA enabled" error, uninstall torch with:

`pip uninstall torch`

And install it again with the command above.

For AMD cards not officially supported by ROCm,
Try running it with this command if you have issues:

For 6700, 6600 and maybe other RDNA2 or older: `HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py`
This is the done by default in the launch script. Feel free to remove/edit it if you want.

For AMD 7600 and maybe other RDNA3 cards: `HSA_OVERRIDE_GFX_VERSION=11.0.0 python main.py`
