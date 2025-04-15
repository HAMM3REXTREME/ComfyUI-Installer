# ComfyUI Installer
Origional Author: https://github.com/HAMM3REXTREME/ComfyUI-Installer
Modified Guided installer.sh by: https://github.com/itsdarklikehell

Easily install ComfyUI + ComfyUI-Manager + ComfyUIMini (in a python venv) on Linux.

Tested on Arch + AMD GPU (by https://github.com/HAMM3REXTREME).

Tested on Ubuntu + Nvidia GPU (https://github.com/itsdarklikehell).

![ComfyUI Screenshot](graphics/comfyui_screenshot.png)
_Note:_ This is not the official ComfyUI icon.

# Installs ComfyUI, ComfyUI Manager and ComfyUIMini in a python venv

## A Quick, Guided install (no .settings file present, it will create one) (SHOULD ALSO WORK ON ALL DISTROS)

You will need to have `python`, `python-venv` and `pip` on your system.
Make sure to install for your GPU Vendor (AMD/NVIDIA):
```sh
git clone https://github.com/itsdarklikehell/ComfyUI-Installer && cd ComfyUI-Installer && ./install.sh
```

## A Quick, Unattended/headless install (i.e one where there is a .settings file present) (SHOULD ALSO WORK ON ALL DISTROS)

You will need to have `python`, `python-venv` and `pip` on your system.
Make sure to install for your GPU Vendor (AMD/NVIDIA):

```sh
git clone https://github.com/itsdarklikehell/ComfyUI-Installer && cd ComfyUI-Installer
```

Create a .settings file containing the following:

```sh
# The directory where the installer is located:
export COMFYUI_INSTALLER_DIR=~/ComfyUI-Installer
# The directory where the ComfyUI is located:
export COMFYUI_DIR=~/ComfyUI-Installer/ComfyUI
# The type of GPU to use:
export GPU=NVIDIA
# The directory where the backups are located:
export BACKUP_DIR=~/ComfyUI-Installer/backup
# The virtual environment directory:
export VIRTUAL_ENV=~/ComfyUI-Installer/ComfyUI/venv
# Use systemd:
export USE_SYSTEMD=true
```

Then run the install script:

```sh
./install.sh
```

## Detailed explation of the installation process:

1. To install ComfyUI using this script, **clone this repo and cd into it**:
   `git clone https://github.com/itsdarklikehell/ComfyUI-Installer && cd ComfyUI-Installer`

2. Then run the install script:
   `./install.sh`
   
   Upon first run, if there is no .settings file present it will ask you for some information and it stores that in a .settings file like this:

   ```sh
   # The directory where the installer is located:
   export COMFYUI_INSTALLER_DIR=~/ComfyUI-Installer
   # The directory where the ComfyUI is located:
   export COMFYUI_DIR=~/ComfyUI-Installer/ComfyUI
   # The type of GPU to use:
   export GPU=NVIDIA
   # The directory where the backups are located:
   export BACKUP_DIR=~/ComfyUI-Installer/backup
   # The virtual environment directory:
   export VIRTUAL_ENV=~/ComfyUI-Installer/ComfyUI/venv
   # Use systemd:
   export USE_SYSTEMD=true
   ```
   
   If do you have a .settings file already present, it will just use that and then proceeds with the installation.

3. When the install script has finished, if you have chosen to use a systemd service, ComfyUI should now be starting/running, you can check the status of the service with:
   `sudo systemctl status ComfyUI.service`
   If it's not running, you can start it with:
   `sudo systemctl start ComfyUI.service`
   If you want to enable it to start on boot, you can do so with:
   `sudo systemctl enable ComfyUI.service`

   If you have chosen not to use systemd, you can start ComfyUI with one of the during installation created run scrips:
   `./scripts/run_gpu.sh`
   or
   `./scripts/run_cpu.sh`.

If everyting has worked, ComfyUI, ComfyUI-Manager and ComfyUIMini should be installed.
Open your browser and go to:
[http://0.0.0.0:8188/](http://0.0.0.0:8188/) to view ComfyUI's interface (Works better on desktop devices/browsers).
[http://0.0.0.0:3000/](http://0.0.0.0:3000/) to view ComfyUIMini's interface (Should work better with mobile devices/browsers).
To check ComfyUI's status, run: `tail -f ComfyUI/logs/comfyui.log` or `journalctl -f -u ComfyUI.service`
To check ComfyUIMini's status, run: `tail -f ComfyUI/custom_nodes/ComfyUIMini/logs/comfyuimini.log` or `journalctl -f -u ComfyUIMini.service`

## Usage

**To Manually launch ComfyUI use**:

 `./scripts/run_gpu.sh`
or
 `./scripts/run_cpu.sh`.


**To Manually launch ComfyUIMini use**:

 `./ComfyUI/custom_nodes/ComfyUIMini/scripts/start.sh`.

**To start ComfyUI systemd service use**:

 `sudo systemctl start ComfyUI.service`

**To start ComfyUIMini systemd service use**:

 `sudo systemctl start ComfyUIMini.service`

**To enable ComfyUI systemd service use**:

 `sudo systemctl enable ComfyUI.service`

**To enable ComfyUIMini systemd service use**:

 `sudo systemctl enable ComfyUIMini.service`

**To stop ComfyUI systemd service use**:

 `sudo systemctl stop ComfyUI.service`

**To stop ComfyUIMini systemd service use**:

 `sudo ystemctl stop ComfyUIMini.service`

**To restart ComfyUI systemd service use**:

 `sudo systemctl restart ComfyUI.service`

**To restart ComfyUIMini systemd service use**:

 `sudo systemctl restart ComfyUIMini.service`

**To check ComfyUI systemd service status use**:

 `sudo systemctl status ComfyUI.service`

**To check ComfyUIMini systemd service status use**:

 `sudo systemctl status ComfyUIMini.service`

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
