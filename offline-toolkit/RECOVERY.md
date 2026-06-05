# 🚑 Disaster Recovery Guide

## Scenario 1: Corrupted Package Database (APT broken)
If `apt` stops working or packages break inside Debian, use the automated repair tool:
1. Open Termux.
2. Run the command: `fix` (or `bash ~/repair.sh`).
3. The tool will flush caches and attempt `dpkg --configure -a`.

## Scenario 2: X11 / Display Server Won't Start
If your desktop environment freezes or Termux:X11 refuses to open:
1. Open a new Termux session.
2. Run `fix`. It explicitly purges stale `.X0-lock` and `.X11-unix/X0` sockets.
3. If it persists, reboot your phone.

## Scenario 3: Broken System (Total Failure)
If the Debian system is completely non-bootable or deeply corrupted:
1. Obtain the `debian-rootfs.tar.zst` offline bundle.
2. Place it in `~/Systemless-Host-Termux-SU/offline-toolkit/`.
3. Run the automated restore script:
   ```bash
   cd ~/Systemless-Host-Termux-SU/offline-toolkit
   ./restore.sh debian-rootfs.tar.zst
   ```
   **Note:** This wipes the existing `/data/local/tmp/chrootDebian`. Make sure you have backed up your `/home/ruusian` directory if possible!

## Scenario 4: Black Screen on Boot (GPU Driver crash)
If the `Zink` driver is causing a total system crash during XFCE startup:
1. Enter the CLI bypass mode: `agy` -> Option 1.
2. Edit `/etc/profile.d/99-hardware-acceleration.sh`.
3. Change `LIBGL_ALWAYS_HW=1` to `LIBGL_ALWAYS_HW=0`.
4. Run `startxfce4` manually to identify the graphics failure.
