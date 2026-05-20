# 🚀 Pro-Termux-Harden (v11.2)
### *The Definitive Infrastructure for High-Performance Mobile Linux.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/Version-11.2--Harden-blue.svg)](https://github.com/Ruusian5/Pro-Termux-Harden)
[![Platform](https://img.shields.io/badge/Platform-Termux--Android-orange.svg)](https://termux.com/)
[![Kernel](https://img.shields.io/badge/Kernel-Bridge--v11.1-red.svg)](https://github.com/Ruusian5/Pro-Termux-Harden)

---

## 🌟 The Vision

**Pro-Termux-Harden** is an industrial-grade deployment suite designed to transform a standard Android Termux environment into a **Fully Autonomous Linux Workstation**. 

By bridging the gap between the Android Kernel and the Debian userland, this project enables near-native performance for **Desktop-Class Development**, **Low-Latency Gaming**, and **Fluid 1080p 60fps Video Playback**. It is optimized for Adreno-powered devices and professional users who demand stability and speed.

---

## 🏗️ System Architecture

The ecosystem is built on four critical layers of hardening:

### 1. The Ultimate Kernel Bridge (V11.2)
Standard Chroots are isolated. Our **Kernel Bridge** breaks these barriers by establishing deep bind-mounts into the Android core:
*   **System Integrity:** Bind-mounts `/apex` and `/linkerconfig` to allow native Android binaries to resolve dependencies correctly.
*   **Hardware Direct-Access:** Maps `/dev/dri`, `/dev/kgsl-3d0`, and `/dev/ion` for zero-latency GPU communication.
*   **Partition Visibility:** Mounts `/odm`, `/vendor`, `/product`, and `/system_ext` so proprietary hardware blobs are visible to the Linux environment.

### 2. High-Performance Graphics (Mesa Zink)
We bypass the slow `llvmpipe` software renderer and utilize a modern **Vulkan-to-OpenGL** pipeline:
*   **Driver:** Mesa Zink running on top of the Turnip (Vulkan) driver.
*   **Profiles:** Forced OpenGL 4.6 / GLSL 460 support to enable modern browser engines (WebRender).
*   **Optimizations:** `vblank_mode=0` for uncapped framerates and `ZINK_DESCRIPTORS=lazy` for reduced CPU overhead.

### 3. Hardened Shell Environment
*   **TTY Bridging:** Uses a specialized `script` tool wrapper to establish proper terminal process groups, resolving the common `Inappropriate ioctl` error.
*   **Environment Sanitization:** Explicitly manages `TMPDIR` and `PATH` to prevent Termux environment leaks from crashing Debian services.
*   **Non-Blocking Startup:** A backgrounded initialization sequence ensures your Termux shell opens instantly while hardware bridges mount in parallel.

### 4. Cinematic Multimedia
*   **Driver Bridge:** Integrated VA-API and VDPAU support via Zink.
*   **Browser-Ready:** Pre-configured environment variables (`MOZ_DISABLE_RDD_SANDBOX`) ensure browsers like Firefox can access GPU decoding for 1080p 60fps video.

---

## 🛠️ Advanced Optimization Parameters

The system comes pre-tuned with the following "Secret Sauce" environment variables:

| Variable | Value | Purpose |
| :--- | :--- | :--- |
| `MESA_LOADER_DRIVER_OVERRIDE` | `zink` | Forces hardware acceleration. |
| `TU_DEBUG` | `noconform` | Speeds up Vulkan execution. |
| `ZINK_DESCRIPTORS` | `lazy` | Maximizes CPU efficiency. |
| `MESA_SHADER_CACHE_MAX_SIZE` | `1G` | Eliminates micro-stuttering. |
| `vblank_mode` | `0` | Disables FPS capping. |

---

## 📟 Control HUD: Ghost Dashboard

The **Command Matrix HUD** is your mission control. It provides a real-time, non-blocking telemetry bar at the top of every terminal session.

### HUD Shortcuts
*   **`1` (LAUNCH):** Starts the XFCE4 Workstation with optimized graphics syncing.
*   **`2` (RESET):** A "Nuclear Shutdown" script that kills all Debian processes and clears graphics locks.
*   **`3` (LINUX):** Instant entry into a TTY-fixed Debian CLI with full hardware autonomy.
*   **`4` (MAINT):** Non-interactive `apt` update/upgrade pipeline.
*   **`5` (TOOLS):** Integrated installer for VS Code, Chromium, Python stacks, and more.
*   **`cmds`:** Toggles the full interactive menu.

---

## 📦 Backup & Replication

This project is designed for **Total Portability**. 

### Create Your Snapshot
Run the included backup engine to create a complete copy of your OS and configurations:
```bash
bash backup.sh
```
This generates:
1.  `debian_chroot.tar.gz`: Your entire hardened Linux OS.
2.  `termux_home.tar.gz`: Your Termux configurations, HUD, and scripts.

### Restoration Guide
To move your setup to a new device:
1. Install Termux & Root the device.
2. Extract `debian_chroot.tar.gz` to `/data/local/tmp/chrootDebian`.
3. Extract `termux_home.tar.gz` to your Home directory.
4. Run `bash ~/mount-debian.sh` to establish the bridge.

---

## 🤝 Developed by Ruusian05
🇷🇺 | *Redefining the boundaries of Mobile Linux.*

Special thanks to the Termux and Mesa communities for the underlying technologies.

---
## 📜 License
Licensed under the **MIT License**. Build something amazing with it.
