# ComfyUI Installer

Easily install ComfyUI + ComfyUI-Manager + ComfyUIMini (in a python venv) on Linux.
Tested on Arch + AMD GPU.
Tested on Ubuntu + Nvidia GPU.

![ComfyUI Screenshot](graphics/comfyui_screenshot.png)
_Note:_ This is not the official ComfyUI icon.

## Quick Start

You will need to have `python`, `pyenv` and `pip` on your system.
Make sure to install for your GPU Vendor (AMD/Nvidia):

```sh
git clone https://github.com/itsdarklikehell/ComfyUI-Installer
cd ComfyUI-Installer
./install.sh --amd for AMD
./install.sh --nvidia for Nvidia
./scripts/menu-entry.sh # Optionally add menu entry
./scripts/run_gpu.sh or ./scripts/run_cpu.sh # Run ComfyUI
./ComfyUI/custom_nodes/ComfyUIMini/scripts/start.sh # Run ComfyUIMini
```

## Installation

1. To install ComfyUI using this script, **clone this repo and cd into it**:
   `git clone https://github.com/itsdarklikehell/ComfyUI-Installer && cd ComfyUI-Installer`

2. After that's done, run the install script for your GPU vendor (AMD or Nvidia). This might take a while.
   **To install for AMD:** `./install.sh --amd`
   **To install for Nvidia:** `./install.sh --nvidia`
   _Tip:_ Afterwards you can optionally run `./scripts/menu-entry.sh` in order to make a desktop menu entry.

3. When the install script has finished, you just need to copy/paste your models into their proper directories:
   Put your SD checkpoints (the huge ckpt/safetensors files) in: `ComfyUI/models/checkpoints`
   Put your VAE in: `ComfyUI/models/vae`

Once you've done that, ComfyUI and ComfyUIMini should be running on your system.
To check ComfyUI's status, run: `tail -f ComfyUI/logs/comfyui.log` or `journalctl -f -u ComfyUI.service`
To check ComfyUIMini's status, run: `tail -f ComfyUI/custom_nodes/ComfyUIMini/logs/comfyuimini.log` or `journalctl -f -u ComfyUIMini.service`

## Usage

**To Manually launch ComfyUI use**: `./scripts/run_gpu.sh` or `./scripts/run_cpu.sh`.
**To Manually launch ComfyUIMini use**: `./ComfyUI/custom_nodes/ComfyUIMini/scripts/start.sh`.
**To start ComfyUI systemd service use**: `sudo systemctl start ComfyUI.service`.
**To start ComfyUIMini systemd service use**: `sudo systemctl start ComfyUIMini.service`.
**To enable ComfyUI systemd service use**: `sudo systemctl enable ComfyUI.service`.
**To enable ComfyUIMini systemd service use**: `sudo systemctl enable ComfyUIMini.service`.
**To stop ComfyUI systemd service use**: `sudo systemctl stop ComfyUI.service`.
**To stop ComfyUIMini systemd service use**: `sudo systemctl stop ComfyUIMini.service`.
**To restart ComfyUI systemd service use**: `sudo systemctl restart ComfyUI.service`.
**To restart ComfyUIMini systemd service use**: `sudo systemctl restart ComfyUIMini.service`.
**To check ComfyUI systemd service status use**: `sudo systemctl status ComfyUI.service`.
**To check ComfyUIMini systemd service status use**: `sudo systemctl status ComfyUIMini.service`.

## Updating

### Updating ComfyUI
Simply re-run the install.sh script which if it detects that ComfyUI is allready installed, it will then proceed to try and update it. Or if it is allready running you could use the ComfyUI-Manager to update everything.

## Troubleshooting

### If you get the "Torch not compiled with CUDA enabled" error

Uninstall torch with:

`pip uninstall torch`

And install it again with the command (for Nvidia) above.

### For AMD cards not officially supported by ROCm

Try running it with this command if you have issues:

For 6700, 6600 and maybe other RDNA2 or older: `HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py`

For AMD 7600 and maybe other RDNA3 cards: `HSA_OVERRIDE_GFX_VERSION=11.0.0 python main.py`

You can add these changes (and other args you want) to `launch.sh` for convenience.
