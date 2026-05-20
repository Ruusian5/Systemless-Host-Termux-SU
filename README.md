# 🚀 Pro-Termux-Harden (v11.2) - The Ultimate Mobile Workstation
### *Turn Any Android Phone into a Professional, Hardware-Accelerated Linux powerhouse.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/Version-11.2--Harden-blue.svg)](https://github.com/Ruusian5/Pro-Termux-Harden)
[![Platform](https://img.shields.io/badge/Platform-Termux--Android-orange.svg)](https://termux.com/)
[![Kernel](https://img.shields.io/badge/Kernel-Bridge--v11.1-red.svg)](https://github.com/Ruusian5/Pro-Termux-Harden)

---

## 🌟 The Vision: "Instant Pro Infrastructure"

**Pro-Termux-Harden** is more than just a set of scripts—it is a complete **Operating System Snapshot**. It is designed to provide a 1:1 replication of a hardened, high-performance Linux environment. Whether you are a developer needing a full VS Code / Python stack or a power user wanting 1080p 60fps video and GPU gaming on Android, this project provides the **Autonomous Infrastructure** to do it.

---

## 🏗️ Technical Architecture & Hardening

The system is engineered for **Near-Native Performance** by bypassing standard Android limitations.

### 1. The Ultimate Kernel Bridge (V11.2)
While standard chroots are "caged," our bridge establishes deep hardware visibility by bind-mounting:
*   **`/apex` & `/linkerconfig`**: Vital for running Android system binaries and resolving native library paths.
*   **`/odm` & `/vendor`**: Provides Debian direct access to proprietary hardware drivers (GPU, Camera, DSP).
*   **`/system_ext` & `/metadata`**: Ensures full system-wide feature parity.
*   **`/dev/dri` & `/dev/kgsl-3d0`**: Unlocks direct Adreno GPU interaction for **Mesa Zink**.

### 2. GPU Autonomy (Mesa Zink 4.6)
We force a modern graphics pipeline to ensure all UI elements and cursors are rendered by hardware:
*   **OpenGL 4.6 / GLSL 460**: Standardized via environment overrides to fix shader extension errors.
*   **Zink + Turnip**: Vulkan-to-OpenGL translation with `TU_DEBUG=noconform` for maximum FPS.
*   **Universal Driver Bridge**: VA-API and VDPAU are pre-configured, allowing browsers like **Firefox** and **Chromium** to decode high-def video autonomously.

### 3. Professional UX Hardening
*   **TTY Fixed Login**: Resolves the "Inappropriate ioctl" error using a native Termux `script` bridge, providing full job control (Ctrl+C/Z).
*   **Ghost HUD Dashboard**: A high-density, non-blocking telemetry bar at the top of every terminal session.
*   **Non-Blocking Boot**: Your shell opens instantly while hardware bridges mount silently in the background.

---

## 🛠️ Instant Conversion Guide (Total Replication)

To entirely convert any Android phone into this high-performance workstation, follow these steps:

### Phase 1: Prerequisite
1.  **ROOT** the device (Mandatory for the Kernel Bridge).
2.  Install **Termux** and **Termux-X11**.

### Phase 2: Rapid Setup
Clone and run the master installer:
```bash
git clone https://github.com/Ruusian5/Pro-Termux-Harden
cd Pro-Termux-Harden
bash setup.sh
```

### Phase 3: Full Restoration (Optional)
If you want the **exact OS snapshot** (with all pre-installed apps and drivers):
1.  Download the `debian_chroot.tar.gz` and `termux_home.tar.gz` from the [Releases](https://github.com/Ruusian5/Pro-Termux-Harden/releases) page.
2.  Extract `debian_chroot.tar.gz` to `/data/local/tmp/chrootDebian`.
3.  Extract `termux_home.tar.gz` to your Termux Home directory.
4.  Run `3` or `cmds` to enter your new workstation.

---

## 📟 Mission Control: HUD Shortcuts

| Shortcut | Action | Technical Result |
| :--- | :--- | :--- |
| `1` | **LAUNCH** | Starts XFCE4 Desktop + Hardware Sync. |
| `2` | **RESET** | Aggressive shutdown of all Debian/X11 processes. |
| `3` | **LINUX** | Autonomous Debian CLI with full TTY support. |
| `4` | **MAINT** | Silent, non-interactive `apt` pipeline. |
| `5` | **TOOLS** | One-click installer for Dev & Design tools. |
| `cmds` | **HUD** | Opens the interactive Mission Control Menu. |

---

## 🤝 Open Source Contribution
Developed by **Ruusian05** 🇷🇺.

We are pushing the boundaries of what is possible on mobile Linux. If you find a performance bottleneck or a kernel path we missed, open an **Issue** or **Pull Request**.

---
## 📜 License
Licensed under the **MIT License**. Build the future of mobile computing with us.
