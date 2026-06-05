# Firefox Configuration Status
**Package:** Firefox ESR (Debian)
**User:** ruusian

## 1. Launch Chain

- **Launcher:** `/usr/local/bin/firefox-launcher`
- **Identity:** `runuser -u ruusian` (Drops root privileges).
- **Environment:**
    - `DISPLAY=:0`
    - `PULSE_SERVER=tcp:127.0.0.1:4713`
    - `MOZ_DISABLE_CONTENT_SANDBOX=1` (Required for chroot namespaces).

---

## 2. Performance Optimizations (user.js)

The following `user_pref` settings are active to ensure stability on Adreno 640:

| Setting | Value | Rationale |
|---------|-------|-----------|
| `security.sandbox.content.level` | `0` | Necessary for execution in a chroot without namespace support. |
| `media.hardware-video-decoding.enabled` | `false` | Disabled to prevent GPU hang/crash on unsupported video formats. |
| `gfx.webrender.compositor.force-enabled` | `true` | Forces hardware acceleration for the browser UI and 2D rendering. |
| `media.av1.enabled` | `false` | AV1 software decoding is too heavy for mobile CPUs; falling back to VP9/H.264. |

---

## 3. Acceleration Status

- **WebRender:** ✅ Hardware (Zink/Turnip).
- **Video Playback:** ⚠️ Software (FFVPX). High-def YouTube (1080p+) may cause high CPU load but is stable.
- **WebGL:** ✅ Full Support (OpenGL 4.6 via Zink).

---

## 4. Verification

- **Audio:** Works via PulseAudio TCP bridge.
- **Networking:** DNS optimization (`disableIPv6: true`) active for faster page loads.

---
**Status:** Firefox Audit Complete. Moving to Phase 7 (VLC).
