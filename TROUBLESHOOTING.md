# 🚑 Troubleshooting & Repair

## Automated Repair
If your workstation becomes unresponsive, audio drops, or the display server freezes, use the built-in repair utility from Termux:
```bash
fix
# or
bash ~/repair.sh
```
This utility will:
1. Clean stale X11 sockets.
2. Flush RAM caches (`drop_caches`).
3. Optimize the CPU governor.
4. Verify Debian package health.

## Common Issues

### Issue: "su: permission denied" or "sudo: unable to resolve host"
**Cause:** Android's `/data` partition mounted with `nosuid`.
**Fix:** The `mount-debian.sh` script automatically attempts to remount `/data` with SUID permissions. Run `agy` -> Option 8 (Reset Bridges) to trigger this.

### Issue: Applications running slowly or crashing with GLX errors
**Cause:** The strict hardware acceleration policy (`LIBGL_ALWAYS_HW=1`) is active. If the `Zink` or `Turnip` drivers cannot communicate with the Adreno GPU, the application will crash rather than falling back to software rendering.
**Fix:** Run `gpu` from Termux to run the hardware diagnostic script. Ensure your device is an Adreno 6xx/7xx.

### Issue: Clipboard not syncing
**Cause:** The background daemon `clipboard-sync.sh` crashed.
**Fix:** Run `fix` to clean up sockets, then `agy` -> Option 0 to restart the desktop environment and background daemons.
