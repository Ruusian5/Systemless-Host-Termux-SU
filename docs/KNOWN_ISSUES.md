# Known Issues & Troubleshooting
**Systemless Host Termux-SU**

## 1. Graphics & Display

### Black Screen on Startup
- **Cause:** XFWM4 Compositing is enabled, causing buffer swap issues with Zink.
- **Fix:** Run `xfconf-query -c xfwm4 -p /general/use_compositing -s false` inside the chroot.

### Black Screen with Zink in Firefox
- **Cause:** WebRender crash or incompatibility.
- **Fix:** Launch Firefox with `MOZ_WEBRENDER=0` or check `user.js` for `gfx.webrender.compositor.force-enabled=false`.

### X11 Timeout
- **Cause:** `termux-x11` server failed to start or bind to socket.
- **Fix:** Ensure the Termux-X11 app has "Display over other apps" permission. Manually open the Termux-X11 app first.

---

## 2. Audio

### No Sound in Guest
- **Cause:** PulseAudio host server not started or TCP bridge blocked.
- **Fix:** Run `pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1"` on host. Check `pactl info` in guest.

### Audio Latency
- **Cause:** TCP overhead or Bluetooth processing.
- **Fix:** Use wired headphones or adjust PulseAudio buffer sizes in `client.conf`.

---

## 3. General Stability

### "Another v2-launch.sh is running"
- **Cause:** Stale PID file in `/tmp/v2-launch.pid`.
- **Fix:** Run `rm -f /data/local/tmp/chrootDebian/tmp/v2-launch.pid`.

### Root Permissions
- **Cause:** GPU nodes (/dev/dri) lost permissions after Android reboot.
- **Fix:** Re-run `bash ~/mount-guest.sh`.

---
**Status:** Documentation Suite Finalized.
