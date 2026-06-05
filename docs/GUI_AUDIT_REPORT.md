# GUI Audit Report - Systemless Host Termux-SU
**Date:** 2026-06-05  
**Lead Engineer:** Gemini CLI (Debian GUI Lead)

---

## 1. Executive Summary
The Debian GUI environment is functional with full hardware acceleration (Zink + Turnip) and PulseAudio bridging. However, the system relies on a complex, manual startup chain (V20) that bypasses `xfce4-session` for stability. While effective, this creates a "split" state between the repository and the runtime that requires reconciliation.

---

## 2. Current Architecture

### 2.1 Host Layer (Termux)
- **OS:** Android 14 (API 34)
- **Device:** LG G8X (Snapdragon 855, Adreno 640)
- **Display Server:** Termux:X11 (v15) running on `:0`.
- **Audio Server:** PulseAudio (v17.0-dirty) with TCP module enabled.

### 2.2 Guest Layer (Debian)
- **Distribution:** Debian 12 (Bookworm) arm64.
- **Desktop Environment:** XFCE 4.18 (minimal component launch).
- **Graphics Stack:** Mesa 26.0.8 utilizing Zink over Turnip Vulkan.
- **Audio Stack:** PulseAudio client routing to `tcp:127.0.0.1:4713`.

---

## 3. Startup Sequence Audit

1. **Android Activity:** `com.termux.x11.MainActivity` is brought to front.
2. **Termux Host:**
    - `pulseaudio --start` (TCP bridge).
    - `termux-x11 :0 -ac -legacy-drawing`.
3. **Bridge Layer:**
    - `mount-guest.sh` binds `/dev`, `/proc`, `/sys`, `/tmp/.X11-unix`, and `/dev/dri`.
4. **Guest Startup:**
    - `v2-launch.sh` (V20) starts as root.
    - Cleans stale locks/sockets.
    - Starts D-Bus system bus.
    - Starts D-Bus session bus as `ruusian`.
    - Manually launches XFCE components: `xfsettingsd`, `xfwm4`, `xfce4-panel`, `xfdesktop`.
    - Watchdog loop (30s) monitors and respawns crashed components.

---

## 4. Graphics & Hardware Acceleration

| Component | Status | Details |
|-----------|--------|---------|
| OpenGL | ✅ Active | Mesa 26.0.8 (zink) |
| Vulkan | ✅ Active | Turnip Adreno (TM) 640 |
| Compositing | ❌ Disabled | Explicitly off to prevent black screens |
| DRI3 | ⚠️ Unknown | Likely active; `termux-x11` supports it |

**Validation:** `glxinfo` confirms `Accelerated: yes`.

---

## 5. Audio System Audit

- **Bridge:** TCP 127.0.0.1:4713.
- **Sink:** `OpenSL_ES_sink` (via Termux).
- **Guest Status:** `pactl info` confirms connection to `Server Name: pulseaudio`.
- **Latency:** Acceptable for desktop use, potential issues with high-bitrate video.

---

## 6. Application Analysis

### 6.1 Firefox ESR
- **Launch Method:** `firefox-launcher` wrapper.
- **Privileges:** Correctly drops to `ruusian`.
- **Sandboxing:** **Disabled** (Required for chroot).
- **Acceleration:** Uses EGL/WebRender.

### 6.2 VLC
- **Launch Method:** Standard `/usr/bin/vlc`.
- **HW Decoding:** Likely failing due to missing permissions on some DRM nodes or codec mismatches.
- **Audio:** Works via PulseAudio bridge.

---

## 7. Technical Debt & Identified Issues

1. **Startup Fragility:** If `termux-x11` crashes, the guest watchdog keeps running but components fail to connect.
2. **Path Hardcoding:** Many scripts in `bin/` still reference `$HOME/Systemless-Host-Termux-SU/scripts` instead of `bin/`.
3. **D-Bus Isolation:** Session bus is manually started; some XFCE plugins may fail to find it if not exported correctly in all environments.
4. **Duplicate Configs:** `configs/debian` (old) and `configs/guest` (new) existed; now consolidated, but `install.sh` needs a full rewrite to match.

---

## 8. Recommendations

1. **Unify Dashboard:** Complete the `scripts` -> `bin` migration across all files.
2. **Harden Watchdog:** The watchdog should check for X11 connectivity, not just process existence.
3. **VLC Optimization:** Investigate `vaapi` or `vdpau` wrappers for Adreno hardware decoding.
4. **Polkit Integration:** Ensure `polkit-gnome-authentication-agent-1` is running for administrative tasks in GUI.

---
**Status:** Audit Phase Complete. Proceeding to Phase 2 (State Reconciliation).
