# ComfyUI Installer
Origional Author: https://github.com/HAMM3REXTREME/ComfyUI-Installer
Modified Guided installer.sh by: https://github.com/itsdarklikehell

Easily install Comfy-Cli + ComfyUI + ComfyUI-Manager (in a python venv) on Linux.

Tested on Arch + AMD GPU (by https://github.com/HAMM3REXTREME).

Tested on Ubuntu + Nvidia GPU (https://github.com/itsdarklikehell).

![ComfyUI Screenshot](graphics/comfyui_screenshot.png)
_Note:_ This is not the official ComfyUI icon.

# Installs Comfy-Cli, ComfyUI and ComfyUI Manager in a python venv

## A Quick, Guided install (i.e where there is no .settings file present in the scripts folder (yet), it should create one) (SHOULD ALSO WORK ON ALL DISTROS)

You will need to have `python`, `python-venv` and `pip` on your system.
Make sure to install for your GPU Vendor (AMD/NVIDIA):
```sh
git clone https://github.com/itsdarklikehell/ComfyUI-Installer && cd ComfyUI-Installer && ./install.sh
```

## A Quick, Unattended/headless install (i.e one where there is a .settings file present/provided in the scripts folder) (SHOULD ALSO WORK ON ALL DISTROS)

You will need to have `python`, `python-venv` and `pip` on your system.
Make sure to install for your GPU Vendor (AMD/NVIDIA):

```sh
git clone https://github.com/itsdarklikehell/ComfyUI-Installer && cd ComfyUI-Installer
```

Create a `scripts/.settings` file containing the following:

```sh
# The directory where the installer is located:
export COMFYUI_INSTALLER_DIR=/media/rizzo/DATA/ComfyUI-Installer
# The virtual environment directory:
export VIRTUAL_ENV=/media/rizzo/DATA/ComfyUI-Installer/venv
# The directory where the ComfyUI is located:
export COMFYUI_DIR=/media/rizzo/DATA/ComfyUI-Installer/ComfyUI
```

Then run the `scripts/install_comfyui.sh` script to install ComfyUI:

```sh
./scripts/install_comfyui.sh
```

## Detailed explation of the guided installation process:

1. To install ComfyUI using this script, **clone this repo and cd into it**:
   `git clone https://github.com/itsdarklikehell/ComfyUI-Installer && cd ComfyUI-Installer`

2. Then run the install script:
   `./install.sh`
   
   Upon first run, if there is no `scripts/.settings` file present in the `scripts` it will ask you for some information and it stores that in the `scripts/.settings` file like this:

   ```sh
   # The directory where the installer is located:
   export COMFYUI_INSTALLER_DIR=/media/rizzo/DATA/ComfyUI-Installer
   # The virtual environment directory:
   export VIRTUAL_ENV=/media/rizzo/DATA/ComfyUI-Installer/venv
   # The directory where the ComfyUI is located:
   export COMFYUI_DIR=/media/rizzo/DATA/ComfyUI-Installer/ComfyUI
   ```
   
   If you do happen have a .settings file already present, it will source that and then proceeds to the menu.

3. Select the install ComfyUI option.

If everyting has worked, ComfyUI and ComfyUI-Manager should be installed.
To start ComfyUI, run `./scripts/run_gpu.sh` or `./scripts/run_cpu.sh`.
Then open your browser and go to:
[http://0.0.0.0:8188/](http://0.0.0.0:8188/) to view ComfyUI's interface (Works better on desktop devices/browsers).
To check ComfyUI's status, run: `tail -f ComfyUI/logs/comfyui.log` or `journalctl -f -u ComfyUI.service`

## Detailed explation of the unattended/headless installation process:
1. To install ComfyUI using this script, **clone this repo and cd into it**:
   `git clone https://github.com/itsdarklikehell/ComfyUI-Installer && cd ComfyUI-Installer`

2. Create a .settings file in the ComfyUI-Installer folder containing the following:
   ```sh
   # The directory where the installer is located:
   export COMFYUI_INSTALLER_DIR=/media/rizzo/DATA/ComfyUI-Installer
   # The virtual environment directory:
   export VIRTUAL_ENV=/media/rizzo/DATA/ComfyUI-Installer/venv
   # The directory where the ComfyUI is located:
   export COMFYUI_DIR=/media/rizzo/DATA/ComfyUI-Installer/ComfyUI
   ```

3. Then run the scripts/install_comfyui.sh script to install ComfyUI:
   `./scripts/install_comfyui.sh`

If everyting has worked, ComfyUI and ComfyUI-Manager should be installed.
To start ComfyUI, run `./scripts/run_gpu.sh` or `./scripts/run_cpu.sh`.
Then open your browser and go to:
[http://0.0.0.0:8188/](http://0.0.0.0:8188/) to view ComfyUI's interface (Works better on desktop devices/browsers).
To check ComfyUI's status, run: `tail -f ComfyUI/logs/comfyui.log` or `journalctl -f -u ComfyUI.service`


## Usage

**To Manually launch ComfyUI use**:
 `./scripts/run_gpu.sh`
or
 `./scripts/run_cpu.sh`.


**To start ComfyUI systemd service use**:
 `sudo systemctl start ComfyUI.service`


**To enable ComfyUI systemd service use**:
 `sudo systemctl enable ComfyUI.service`


**To stop ComfyUI systemd service use**:
 `sudo systemctl stop ComfyUI.service`


**To restart ComfyUI systemd service use**:
 `sudo systemctl restart ComfyUI.service`


**To check ComfyUI systemd service status use**:
 `sudo systemctl status ComfyUI.service`


## Updating

### Updating ComfyUI
Simply re-run the install.sh script, it should detect that ComfyUI is already installed and then proceed to try and update it. Or if it is already running you could use the ComfyUI-Manager to update everything.

## Troubleshooting

### If you get the "Torch not compiled with CUDA enabled" error

Uninstall torch with:

`pip uninstall torch`

And install it again with the command (for Nvidia) above.

### For AMD cards not officially supported by ROCm

Try running it with this command if you have issues:

For 6700, 6600 and maybe other RDNA2 or older: `HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py`

For AMD 7600 and maybe other RDNA3 cards: `HSA_OVERRIDE_GFX_VERSION=11.0.0 python main.py`

You can add these changes (and other args you want) to `scripts/run_gpu.sh` for convenience.