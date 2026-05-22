# 🚀 Pro-Termux-Harden (v13.0 Ultimate Edition)
### *Professional Hardware-Accelerated Linux Workstation for Android*

This repository is a complete, anonymized extraction of a highly-tuned Debian chroot environment. It features full **Adreno 640 GPU acceleration**, professional TTY emulation, and synchronized PulseAudio.

---

## 📖 Complete Installation & Setup Guide

### 1. Initial Deployment
If you are starting from zero, clone this repo and run the automated installer:
```bash
git clone https://github.com/Ruusian5/Systemless-Host-Termux-SU.git
cd Systemless-Host-Termux-SU
chmod +x setup.sh
./setup.sh
```

### 2. Restoring the Environment (Snapshot)
The scripts in this repo are logic-only. To get the actual Debian OS, you need a RootFS snapshot.
1. Place your `debian_chroot.tar.gz` in `/sdcard/ProTermux-Backups/`.
2. Run the restore tool:
   ```bash
   bash scripts/restore-env.sh
   ```

### 3. GPU Acceleration Handshake
This workstation uses **Mesa 26.0 (Sid)** and the **Turnip KGSL** driver.
- The `mount-debian.sh` script bind-mounts your GPU nodes (`/dev/kgsl-3d0`).
- The `99-hardware-acceleration.sh` profile forces **Zink** (OpenGL-over-Vulkan) for 100% hardware speed.

---

## 🎮 Operations Manual

| Command | Action | Description |
| :--- | :--- | :--- |
| `1` | **Launch Desktop** | Starts XFCE4 + Picom (GPU Compositor). |
| `3` | **Linux CLI** | Instant TTY bridge with full DBus connectivity. |
| `4` | **Maintenance** | Non-interactive system-wide updates. |
| `stop` | **Kill System** | Safely unmounts and wipes stale locks. |

---

## 🔧 Troubleshooting (Developer Tips)
- **Firefox Lag:** Check `~/firefox_engine.log`. Ensure `MOZ_DISABLE_RDD_SANDBOX=1` is active.
- **Display Error:** Ensure the **Termux-X11** app is running in the background before typing `1`.
- **Audio Issues:** Run `pulseaudio --start` in Termux if sound is missing.

---

## 🛡️ Privacy Notice
**This repository is anonymized.** 
- All API Keys and Personal Access Tokens have been removed.
- All personal emails and identifiers have been scrubbed from scripts.
- Only the system logic and hardware optimizations remain.

---

## 📜 License
MIT License. Optimized and maintained for the community.
