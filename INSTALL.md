# ⚡ Pro Workstation Edition v0.1

## Installation Guide

### Prerequisites
1. A rooted Android device (Magisk/KernelSU).
2. Termux installed.
3. Debian chroot filesystem extracted to `/data/local/tmp/chrootDebian`.

### Automated Installation
Run the following commands in Termux to install all host dependencies and configure the Debian bridges automatically:

```bash
git clone https://github.com/Ruusian5/Systemless-Host-Termux-SU.git
cd Systemless-Host-Termux-SU
chmod +x install.sh
./install.sh
```

### Post-Installation
After the installer finishes:
1. Fully restart Termux.
2. Type `agy` to open the Mission Control Dashboard.
3. Use option `1` to launch the Desktop and `2` to enter the CLI.

### Upgrading
To upgrade an existing installation without breaking configurations:
1. Pull the latest repository changes.
2. Run `install.sh` again. It is designed to be idempotent and safe.
