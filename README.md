# 🚀 Pro-Termux-Harden (v0.3)
### *Advanced Hardware-Accelerated Linux Workstation for Android*

Welcome to the definitive Debian chroot environment for Termux. This project transforms your Android phone into a professional, desktop-grade workstation with full Adreno GPU support, low-latency audio, and professional TTY emulation.

---

## 🌟 Key Features
- **Universal Clipboard Sync:** Seamlessly copy and paste text between your Android host and the Linux X11 session.
- **Legacy Drawing Patch:** Fixes the "Blank GUI" issue on older kernels by forcing Termux-X11 compatibility mode while preserving Zink acceleration for applications.
- **Neon Alt-Screen TUI:** A high-performance, interactive dashboard for system management that uses a flicker-free alternate screen buffer.
- **Mesa 26.0 (Sid) Stack:** Cutting-edge graphics pipeline with Zink + Turnip (KGSL) support.
- **Pro TTY Emulation:** Flawless Linux terminal experience with full job control and correct PTY allocation via Python.
- **Synchronized Audio:** Low-latency PulseAudio bridging between Termux and Debian.

## 🚀 Installation & Restoration
### 1. Prerequisites
- **Rooted Android Device** (Required for hardware node mounting).
- **Termux** & **Termux-X11** App installed.
- **Aarch64 Architecture** (Snapdragon 845 or newer recommended).

### 2. Automatic Setup
1. Clone this repository:
   ```bash
   git clone https://github.com/Ruusian5/Systemless-Host-Termux-SU.git
   cd Systemless-Host-Termux-SU
   ```
2. Run the installer:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

### 3. Restoring the Master Snapshot
To get the full Debian OS, you must download the system snapshot:
1. Go to the [Releases](https://github.com/Ruusian5/Systemless-Host-Termux-SU/releases) page.
2. Download all `debian_v13_snapshot.tar.gz.part_*` files.
3. Move them to `/sdcard/ProTermux-Backups/`.
4. Recombine and restore:
   ```bash
   cat /sdcard/ProTermux-Backups/debian_v13_snapshot.tar.gz.part_* > /sdcard/ProTermux-Backups/debian_chroot.tar.gz
   bash ~/restore-env.sh
   ```

---

## 🎮 Operations Manual
Use the `cmds` alias to launch the Neon TUI, or use direct shortcuts from your terminal:

| Shortcut | Command | Action |
| :--- | :--- | :--- |
| `1` | **Launch Desktop** | Starts XFCE4 with high-speed GPU compositing. |
| `3` | **Linux CLI** | Drops you into a professional, bus-connected Linux shell. |
| `4` | **Maintenance** | Auto-update Debian and clean system caches. |
| `stop` | **Kill System** | Safely unmounts hardware nodes and clears session locks. |
| `cmds` | **Mission Control** | Opens the interactive HUD menu. |

---

## 🔧 Technical Pipeline (The "Bare Metal" Magic)
- **GPU:** Uses the **Zink** driver to translate OpenGL to Vulkan, which then speaks directly to the **Adreno 640** via the **Turnip KGSL** bridge.
- **Audio:** PulsAudio is bridged via TCP (localhost) to ensure zero-lag synchronization during video playback.
- **Clipboard:** A custom background daemon polls `termux-api` and `xclip` to keep the host and chroot clipboards perfectly synced.
- **Security:** The system is **anonymized**. No API keys, personal emails, or credentials are included in this backup.

---

## 📜 License
MIT License. Optimized for the mobile Linux community.
