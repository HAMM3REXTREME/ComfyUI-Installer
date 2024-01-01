# ComfyUI Installer

Easily install ComfyUI (in a python venv) on Linux.
Tested on Arch + AMD GPU.

![ComfyUI Screenshot](pictures/comfyui_screenshot.png)

# Quick Start

1. To install ComfyUI using this script, **clone this repo and cd into it**:  
   `git clone https://github.com/HAMM3REXTREME/ComfyUI-Installer && cd ComfyUI-Installer`

2. After that is completed, install for either AMD or Nvidia.  
   **To install for AMD:** `./install.sh --amd`  
   **To install for Nvidia:** `./install.sh --nvidia`

3. Almost done! You can now get your models and put them in their proper directories:  
   Put your SD checkpoints (the huge ckpt/safetensors files) in: `ComfyUI/models/checkpoints`  
   Put your VAE in: `ComfyUI/models/vae`

Once that is done, **launch comfyUI using**: `cd ComfyUI && ./ComfyUI`

# Installing or upgrading python venv packages:

While in the ComfyUI folder, run `source comfy-venv/bin/activate` in order to access the python venv.  
(The installer creates the python venv inside the ComfyUI folder by default.)

**Note:** You can pass `--update` in a `pip` command in order to update packages instead of installing.

**Note:** pytorch stable does not support python 3.12 yet. If you have python 3.12 you will have to use the nightly version of pytorch. If you run into issues you should try python 3.11 instead.

#### AMD GPUs (Linux only)

AMD users can install rocm and pytorch with pip if you don't have it already installed, this is the command to install the stable version:

`pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6` (Installer default for AMD)

This is the command to install the nightly with ROCm 5.6 that supports the 7000 series and might have some performance improvements:

`pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm5.7`

#### NVIDIA

Nvidia users should install stable pytorch using this command:

`pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121` (Installer default for Nvidia)

This is the command to install pytorch nightly instead which has a python 3.12 package and might have performance improvements:

`pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121`

#### Dependencies

Install the dependencies by opening your terminal inside the ComfyUI folder and:

`pip install -r requirements.txt`

After this you should have everything installed and can proceed to running ComfyUI.

#### Troubleshooting

If you get the "Torch not compiled with CUDA enabled" error, uninstall torch with:

`pip uninstall torch`

And install it again with the command above.

For AMD cards not officially supported by ROCm,
Try running it with this command if you have issues:

For 6700, 6600 and maybe other RDNA2 or older: `HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py`
This is the done by default in the launch script. Feel free to remove/edit it if you want.

For AMD 7600 and maybe other RDNA3 cards: `HSA_OVERRIDE_GFX_VERSION=11.0.0 python main.py`
