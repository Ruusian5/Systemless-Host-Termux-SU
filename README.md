<div align="center">

# Systemless-Host-Termux-SU

**Enterprise Debian Workstation on Rooted Android**

Full Linux desktop environment inside a real chroot on Android,  
with XFCE desktop, PulseAudio, Hermes AI gateway, and clipboard sync.

[Features](#features) - [Quick Start](#quick-start) - [Usage](#usage) - [Troubleshooting](#troubleshooting)

</div>

---

## Features

| Capability | Status |
|------------|--------|
| Real chroot (not proot) | Native ARM64 performance |
| XFCE Desktop via Termux:X11 | Full window manager + panel |
| Audio (PulseAudio over TCP) | Android speaker via OpenSL ES |
| Clipboard sync (bidirectional) | Android to X11 |
| Hermes AI Gateway | Nous Research agent with NVIDIA NIM |
| Kernel bypass (fix_mmap.so) | Patches broken close_range syscall |
| Dashboard TUI | All system operations in one menu |

## Quick Start

### Prerequisites
- Rooted Android device (ARM64)
- Termux from F-Droid
- Termux:X11 APK
- ~5 GB free storage

### Installation

```bash
pkg install -y git busybox
git clone https://github.com/Ruusian5/Systemless-Host-Termux-SU.git
cd Systemless-Host-Termux-SU
bash install.sh
# Extract Debian rootfs to /data/local/tmp/chrootDebian
# (Available from releases page)
gui
```

### Quick Start After Setup

```
gui        -> Start desktop    |  stopgui  -> Stop desktop
agy        -> Open dashboard    |  debian   -> Login as root
ruusian    -> Login as user     |  fix      -> Repair system
```

Keep the gui terminal open - closing it stops the desktop.  
Open Termux:X11 app on your device separately.

## Usage

### Dashboard (agy)

```
  [1]  Start GUI       [2]  Stop GUI
  [3]  Mount Chroot    [4]  Unmount
  [5]  Repair          [6]  GPU Audit
  [7]  PulseAudio      [8]  Fix Audio
  [9]  Login root      [10] Login ruusian
  [11] Hermes Gate     [12] Hermes (sudo)
  [13] Backup          [14] Clipboard Sync
  [15] Clear Cache     [q]  Quit
```

### Hermes AI Gateway

Configure NVIDIA NIM keys in ~/.hermes/.env:
```
NVIDIA_API_KEY=nvapi-your-key-here
NVIDIA_API_KEY_2=nvapi-backup-key
NVIDIA_API_KEY_3=nvapi-backup-key-2
```

## Architecture

```
Android Host
  +-- Termux:X11 (X Server)
  +-- PulseAudio (OpenSL ES sink)
  +-- Debian 12 Chroot (ARM64 native)
       +-- XFCE Desktop (xfwm4 + tint2)
       +-- fix_mmap.so (close_range bypass)
       +-- Hermes Gateway (AI agent)
       +-- GPU compute (OpenCL/Vulkan)
```

### Key Scripts

| Script | Role |
|--------|------|
| mount-debian.sh | Bind-mounts /dev, /proc, /sys, /tmp |
| startxfce4_chrootDebian.sh | Launches X server + desktop |
| v2-launch.sh | Chroot init (dbus, hardware) |
| user-session.sh | Starts XFCE as ruusian user |
| fix_mmap.c | Kernel 4.14 syscall patches |
| repair.sh | Package health, X11, CPU governor |
| gpu-audit.sh | Adreno GPU diagnostics |
| cmds.sh | Dashboard TUI |

## Troubleshooting

### Black screen in Termux:X11
```
fix          Clean X sockets + fix permissions
gui          Restart desktop
```

### Audio not working
```
fixaudio     Restart PulseAudio with OpenSL ES sink
```

### 100% CPU spin loops
The fix_mmap.so preload library patches the broken close_range syscall.
Verify: cat /etc/ld.so.preload (should show /home/ruusian/fix_mmap.so)

---

Built for rooted Android + Linux enthusiasts
