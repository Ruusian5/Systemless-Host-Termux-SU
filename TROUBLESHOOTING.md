# 🚑 Troubleshooting & Repair

## Automated Repair
If your workstation becomes unresponsive, audio drops, or the display server freezes, use the built-in repair utility from Termux:
```bash
bash ~/cmds.sh   # then choose [6] Clean & Repair
# or directly:
bash ~/repair.sh
```
This utility will:
1. Clean stale X11 sockets.
2. Verify Debian package health (`dpkg --configure -a`, `apt-get install -f`).
3. Run `fstrim` on `/data`.
4. Truncate logs and clear the APT cache.

> Note: `repair.sh` no longer flushes RAM caches or changes the CPU governor (those operations are skipped to avoid destabilizing the host).

## Common Issues

### Issue: "su: permission denied" / "sudo: effective uid is not 0" inside the chroot
**Cause:** Android's `/data` partition is mounted `nosuid`, which breaks setuid binaries (`sudo`/`su`) inside the chroot.
**Fix:** `mount-debian.sh` and `startxfce4_chrootDebian.sh` automatically remount `/data` with `suid`. Run the dashboard (`bash ~/cmds.sh`) → **[3] Mount Chroot** (or **[1] Start GUI**) to trigger it. The chroot `ruusian` sudo password is `1234`.

### Issue: Applications running slowly or crashing with GLX errors
**Cause:** Turnip (Vulkan) + Zink (OpenGL-on-Vulkan) translation on the Adreno 640. If the drivers cannot reach the GPU, the app may fail rather than fall back to software rendering.
**Fix:** Run `bash ~/gpu-info.sh` (dashboard **[8] GPU Info**) for a hardware diagnostic. Ensure your device is an Adreno 6xx/7xx.

### Issue: GNOME Software will not launch
**Cause:** GNOME Software 43.5 crashes on EGL/DRI3 init ("lost connection to rendering server") under Turnip+Zink — unfixable in this environment.
**Fix:** Use **Synaptic** instead — dashboard **[9] Synaptic Pkg Mgr**, or the Synaptic icon on the desktop. If it shows no packages, run `sudo apt update` first.

### Issue: Clipboard not syncing
**Cause:** The background daemon `clipboard-sync.sh` crashed.
**Fix:** Run dashboard **[2] Stop GUI** then **[1] Start GUI** (or **[10] Restart GUI**) to restart the desktop environment and background daemons.
