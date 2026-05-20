# Pro-Termux-Harden (v11.2) 🚀

Transform your Android Termux environment into a professional, hardware-accelerated Linux workstation with total autonomy.

![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-11.2--Harden-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Termux--Android-orange.svg)

## 🌟 Overview

**Pro-Termux-Harden** is a suite of advanced scripts designed to establish a high-performance Debian Chroot environment with an **Ultimate Kernel Bridge**. It bridges the gap between Android hardware and Linux, enabling full GPU acceleration (Mesa Zink), high-def video playback (1080p 60fps), and a professional HUD interface.

### ✨ Key Features

*   **🛡️ Ultimate Kernel Bridge (v11.1):** Bind-mounts all critical Android partitions (`/apex`, `/odm`, `/product`, etc.) for total hardware autonomy.
*   **🎮 Mesa Zink Acceleration:** High-performance OpenGL 4.6 and Vulkan support for Adreno GPUs.
*   **📺 1080p 60fps Video:** Native VA-API/VDPAU hardware decoding support for browsers and media players.
*   **📟 Command Matrix HUD:** A minimal, high-density dashboard banner with live telemetry and instant shortcuts.
*   **⚡ Non-Blocking Startup:** Your shell opens instantly while hardware initialization happens in the background.
*   **🔧 Professional Hardening:** Robust error handling, absolute path reliability, and TTY-fixed terminal sessions.

---

## 🛠️ Installation

### 1. Prerequisite
Ensure you have **Termux** and **Termux-X11** installed. You will also need root access on your device for the Kernel Bridge to function.

### 2. Setup
Clone this repository and run the installer:

```bash
git clone https://github.com/Ruusian05/Pro-Termux-Harden
cd Pro-Termux-Harden/scripts
bash chroot_debian_installer.sh
```

---

## 🚀 Usage

Once installed, you can control your entire system using the **Shortcuts** or the **HUD**.

### Instant Shortcuts (Aliases)
*   **`1`**: Launch XFCE4 Graphical Workstation.
*   **`2`**: Force Reset/Stop all Debian processes.
*   **`3`**: Open Autonomous Linux Terminal (Debian CLI).
*   **`4`**: Run Non-Interactive Debian Maintenance.
*   **`5`**: Open Dev Tool Installer.
*   **`cmds`**: Open the full Command Matrix HUD menu.

---

## 📂 Repository Structure

*   `/scripts`: Hardened automation scripts for mounting, launching, and installing.
*   `/configs`: Optimized `.bashrc` and hardware acceleration profiles.
*   `README.md`: Documentation and setup guide.

---

## 🤝 Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Developed by Ruusian05** 🇷🇺 | *Pushing the limits of Mobile Linux.*
