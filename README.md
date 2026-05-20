# 🚀 Pro-Termux-Harden (v11.2)
### *Transform Your Android into a Professional Linux Powerhouse.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/Version-11.2--Harden-blue.svg)](https://github.com/Ruusian05/Pro-Termux-Harden)
[![Platform](https://img.shields.io/badge/Platform-Termux--Android-orange.svg)](https://termux.com/)

---

## 🌟 The Vision

**Pro-Termux-Harden** is not just a script collection; it's a **total infrastructure upgrade** for Termux. It bridges the gap between Android’s hardware and the Linux userland, providing a stable, high-performance environment for developers, power users, and Linux enthusiasts.

---

## ⚡ Key Highlights

*   **🛡️ Ultimate Kernel Bridge (v11.2):** Autonomous access to `/apex`, `/odm`, `/product`, and other critical partitions.
*   **🎮 True GPU Acceleration:** Native **Mesa Zink** integration for Adreno GPUs, providing OpenGL 4.6 and Vulkan support.
*   **📺 Cinematic Playback:** Hardened VA-API/VDPAU driver bridges for **1080p 60fps** smooth video in browsers and media players.
*   **📟 Ghost HUD Dashboard:** A sleek, non-blocking terminal banner with live telemetry (CPU, RAM, Temp, Battery, IP).
*   **⚙️ Industrial Hardening:** Surgical error handling, absolute path mapping, and TTY-fixed terminal sessions.

---

## ⚠️ Prerequisites (Mandatory)

To use this system effectively, you **must** meet the following requirements:

1.  **ROOT Access:** Necessary for establishing the Kernel Bridge and hardware partitions.
2.  **Termux-X11:** Required for Graphical (XFCE4) Workstation support.
3.  **Debian Chroot:** Designed to run with a Debian-based environment (provided by the installer).

---

## 🛠️ Rapid Deployment

Execute the all-in-one setup to transform your environment instantly:

```bash
git clone https://github.com/Ruusian05/Pro-Termux-Harden
cd Pro-Termux-Harden
bash setup.sh
```

---

## 📟 Control HUD Shortcuts

Once installed, use these instant aliases directly in your terminal:

| Key | Action | Description |
| :--- | :--- | :--- |
| `1` | **LAUNCH** | Starts the XFCE4 Graphical Workstation. |
| `2` | **RESET** | Terminates all Debian processes and cleans locks. |
| `3` | **LINUX** | Drops you into an autonomous Debian CLI (Fixed TTY). |
| `4` | **MAINT** | Runs silent, non-interactive package updates. |
| `5` | **TOOLS** | Opens the Debian Dev Tool Installer menu. |
| `cmds` | **HUD** | Opens the interactive Command Matrix Menu. |

---

## 🤝 Community & Support

Developed with ❤️ by **Ruusian05** 🇷🇺.

Found a bug? Have a request for the v12.0 update? Open an **Issue** or submit a **Pull Request**.

---

## 📜 License

This project is licensed under the **MIT License**. Use it, break it, improve it.

---
**[!] Warning:** *Modifying kernel-level bridges involves root access. Proceed with knowledge and caution.*
