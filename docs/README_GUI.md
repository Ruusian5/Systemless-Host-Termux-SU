# GUI Infrastructure Guide
**Project:** Systemless Host Termux-SU
**Role:** GUI Infrastructure Lead

---

## 1. Architecture Overview

This project implements a **layered GUI stack** to provide a full Linux workstation experience on Android.

### 1.1 Layers
1. **Android Layer:** Provides the `MainActivity` surface and hardware drivers.
2. **Termux Host Layer:** Runs the display server (`termux-x11`) and audio server (`pulseaudio`).
3. **Bridge Layer:** Manages kernel bind mounts (`mount-guest.sh`) and hardware node mapping (`/dev/kgsl-3d0`).
4. **Debian Guest Layer:** Runs the XFCE desktop and applications within a hardened chroot.

---

## 2. Startup Flow (The "V20" Pipeline)

The system uses a highly optimized, idempotent startup chain:

1. **Host Initialization (`start-gui.sh`):**
    - Checks for stale X11 sockets and PulseAudio instances.
    - Brings the Termux:X11 Android surface to the foreground.
    - Launches `termux-x11 :0` with `-legacy-drawing` for stability.
2. **Bridge Phase (`mount-guest.sh`):**
    - Mounts `/dev`, `/proc`, `/sys`, and `/tmp/.X11-unix`.
    - Maps Adreno GPU nodes for hardware acceleration.
3. **Guest Phase (`v2-launch.sh`):**
    - **Cleanup:** Force-kills stale XFCE/D-Bus/GVFS processes.
    - **Hardware Profile:** Loads Mesa environment variables (Zink + Turnip).
    - **D-Bus:** Starts system and session buses.
    - **Identity:** Drops from `root` to `ruusian` for session security.
    - **Desktop Launch:** Manually starts XFCE components (Panel, WM, Desktop) without `xfce4-session` to bypass systemd/logind dependencies.
    - **Watchdog:** Monitors process liveness every 30s and respawns components.

---

## 3. Graphics & Audio Flow

### 3.1 Graphics
- **Renderer:** Zink (OpenGL 4.6) → Turnip (Vulkan 1.3) → KGSL (Android Kernel).
- **Status:** Full hardware acceleration for WebGL and 3D applications.
- **Constraints:** Compositing is **DISABLED** to prevent black-screen buffer conflicts.

### 3.2 Audio
- **Routing:** Guest Apps → PulseAudio Client → TCP (127.0.0.1:4713) → Host PulseAudio → Android Audio.
- **Status:** Bi-directional audio support for browser and media players.

---

## 4. User Experience Details

- **Default User:** `ruusian`
- **Browsing:** Firefox ESR (Sandboxing disabled for chroot compatibility).
- **Media:** VLC (Configured for X11/PulseAudio output).
- **Themes:** Arc-Dark (Consistent GTK3 aesthetic).

---

## 5. Known Problems & Opportunities

### Problems
- **Watchdog Desync:** If X11 server dies, guest processes keep running but become "headless."
- **Browser Sandboxing:** Disabled sandboxing reduces security; mitigation is running as a non-privileged user.

### Opportunities
- **Performance:** Potential to optimize startup by parallelizing D-Bus and X11 initialization.
- **Visuals:** Picom integration could provide a safer alternative to XFWM4 compositing.

---
**Status:** README_GUI Finalized.
