# ⚡ Pro Workstation Edition v0.1 (Hardened)
### BY RUUSIAN

A high-performance, hardware-accelerated Debian environment for Android via Termux. This project transforms your rooted device into a production-grade Linux workstation with full GPU acceleration, integrated audio, and universal clipboard sync.

---

## 🚀 Key Features
*   **Hardware Acceleration**: Native Adreno GPU support via Turnip + Zink drivers (Mesa 26.1).
*   **Enterprise Hardening**: Resolved Android SUID restrictions; idempotent kernel bridges.
*   **Workstation Suite**: Pre-configured **Firefox ESR** (with uBlock Origin) and **VLC Media Player**.
*   **Integrated Dev Stack**: Fully functional **Node.js**, **NPM**, **Curl**, and **APT** inside Debian.
*   **Mission Control Dashboard**: Advanced TUI (`agy`) for system vitals and one-tap controls.
*   **Universal Sync**: Shared clipboard and high-speed audio bridge between Android and Debian.

---

## 🛠 Installation

1.  **Extract your Debian Chroot** to `/data/local/tmp/chrootDebian`.
2.  **Clone this Repo** into your Termux home.
3.  **Run the Hardened Installer**:
    ```bash
    cd Systemless-Host-Termux-SU
    bash install.sh
    ```
4.  **Launch Dashboard**:
    ```bash
    agy
    ```

---

## 🎮 GPU Performance
This project prioritizes **Zink + Turnip** for maximum OpenGL/Vulkan performance. 
*   **Default Renderer**: `zink` (Adreno 640/KGSL).
*   **Firefox Hooks**: Policy-driven hardware acceleration and sandbox bypasses for high-FPS browsing.
*   **VLC Hooks**: Direct `gles2` output for smooth HD video playback.

---

## 📂 Project Structure
*   `scripts/cmds.sh`: The Mission Control Dashboard.
*   `scripts/mount-debian.sh`: Enterprise kernel bridge with SUID remounting.
*   `scripts/startxfce4_chrootDebian.sh`: Super-level session launcher.
*   `scripts/repair.sh`: Deep-clean and system optimization utility.
*   `configs/debian/`: Pre-configured environment hooks for the guest OS.

---

## 🛡 Security & Reliability
*   **Continuous Uptime**: Designed for months of continuous operation without rebooting.
*   **Idempotent Bridges**: Scripts detect existing mounts to prevent system locks.
*   **Graceful Shutdown**: 2-stage termination (SIGTERM -> SIGKILL) to prevent zombie processes.

**VERSION 0.1 | HARDENED | BY RUUSIAN**
