# 🚀 Pro-Termux-Harden (v11.2)
### *The Ultimate Autonomous Linux Workstation for Android.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/Version-11.2--Harden-blue.svg)](https://github.com/Ruusian5/Pro-Termux-Harden)
[![Platform](https://img.shields.io/badge/Platform-Termux--Android-orange.svg)](https://termux.com/)

---

## 🌟 The Vision

**Pro-Termux-Harden** is a professional-grade infrastructure suite that transforms Termux into a high-performance, autonomous Linux environment. It is designed to bridge the deep gap between Android's locked kernel interfaces and a standard Linux userland, providing a stable platform for **Desktop-Class Development**, **Hardware-Accelerated Gaming**, and **Fluid 1080p Video Playback**.

---

## ⚡ Technical Deep-Dive

This repository contains the "Master Setup" used to achieve near-native performance on ARM64 hardware.

### 🛡️ Ultimate Kernel Bridge (v11.2)
Unlike standard chroots that only mount `/dev` and `/proc`, our **Kernel Bridge** establishes an autonomous hardware link. It bind-mounts:
*   **`/apex` & `/linkerconfig`**: Vital for running Android system binaries and native libraries.
*   **`/odm` & `/vendor`**: Direct access to proprietary hardware drivers (GPU, Camera, DSP).
*   **`/system_ext` & `/metadata`**: Ensures full system-wide feature visibility.
*   **`/dev/dri` & `/dev/kgsl-3d0`**: Unlocks direct Adreno GPU interaction for Mesa Zink.

### 🎮 Mesa Zink & GPU Autonomy
We leverage **Mesa Zink** (OpenGL over Vulkan) to provide a modern graphics pipeline. 
*   **OpenGL 4.6 / GLSL 460 Support**: Enables modern rendering engines like WebRender.
*   **Vulkan Turnip Driver**: Optimized for Adreno 6xx/7xx series GPUs.
*   **Shader Caching**: Pre-configured 1GB cache to eliminate stuttering in apps and browsers.

### 📺 Cinematic 1080p 60fps Playback
Hardened VA-API/VDPAU driver bridges ensure that browsers like **Firefox** and **Chromium** autonomously detect and use the GPU for video decoding.

---

## ⚠️ Prerequisites (Mandatory)

1.  **ROOT Access:** Required for Kernel Bridge mounting.
2.  **Termux-X11:** Required for the high-performance graphics bridge.
3.  **Busybox:** Used for lightning-fast, robust mounting.

---

## 🛠️ Rapid Deployment & Replication

### Option A: Standard Script Setup
Install the hardened scripts and HUD on your existing Debian environment:

```bash
git clone https://github.com/Ruusian5/Pro-Termux-Harden
cd Pro-Termux-Harden
bash setup.sh
```

### Option B: Full System Backup/Restore
This repository supports full system replication. Use the built-in backup tool to move your entire setup to another device:

1.  **To Backup:** `bash backup.sh` (Creates snapshots in `/sdcard/ProTermux-Backups`).
2.  **To Restore:** Simply extract `debian_chroot.tar.gz` to `/data/local/tmp/chrootDebian` and `termux_home.tar.gz` to your Termux HOME.

---

## 📟 Control HUD Shortcuts

| Key | Action | Description |
| :--- | :--- | :--- |
| `1` | **LAUNCH** | Starts the XFCE4 Graphical Workstation (Fast Sync). |
| `2` | **RESET** | Nuclear shutdown of all Debian/Graphics processes. |
| `3` | **LINUX** | Drops you into an autonomous Debian CLI (Fixed TTY Bridge). |
| `4` | **MAINT** | Silent, non-interactive system maintenance. |
| `5` | **TOOLS** | Debian Dev Tool Installer (VS Code, Chromium, etc.). |
| `cmds` | **HUD** | Opens the interactive Command Matrix Menu. |

---

## 🤝 Developed by Ruusian05
🇷🇺 | *Redefining the boundaries of Mobile Linux.*

This project is open-source under the **MIT License**. We encourage forks, improvements, and community hardening.

---
**[!] Warning:** *Kernel-level bridging is a powerful tool. Proceed with caution.*
