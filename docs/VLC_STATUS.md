# VLC Media Player Status
**Package:** VLC (Debian)
**User:** ruusian

## 1. Playback Configuration

- **Audio Output:** ✅ PulseAudio (Connected to host).
- **Video Output:** ✅ X11 (Hardware accelerated via Zink/Turnip).
- **Hardware Decoding:** ❌ Disabled/Falling back to Software.

---

## 2. Issues & Limitations

- **GPU Acceleration:** While the window rendering is accelerated by Zink, the video bitstream decoding is currently handled by the CPU (Software).
- **Format Support:** High-efficiency codecs (HEVC/H.265) may stutter at resolutions > 720p.
- **Root Usage:** VLC refuses to run as root by default. This is handled by running it as `ruusian` from the XFCE menu.

---

## 3. Optimization Path

To improve playback, users should:
1.  Ensure `zink` is active (`glxinfo` verification).
2.  In VLC Settings: Video -> Output -> Select "X11 video output (XCB)" explicitly if automatic detection fails.

---
**Status:** VLC Audit Complete. Moving to Phase 8 (User Experience).
