# 🏗 Architecture & Design

## System Overview
This project bridges an Android Termux host environment with a full Debian chroot guest environment. It is designed for developers who need native Linux tools side-by-side with Android.

### 1. Host Layer (Termux)
- Acts as the mission controller and bridge manager.
- Runs `termux-x11` (X11 Display Server).
- Runs `pulseaudio` (Audio Server over TCP).
- Hosts the `clipboard-sync.sh` daemon for universal copy/paste.

### 2. Kernel Bridge Layer
- `mount-debian.sh` remounts `/data` to remove `nosuid` restrictions, allowing `su` and `sudo` to work inside the chroot.
- Exposes Android hardware nodes (`/dev/kgsl-3d0`, `/dev/dri`, `/dev/ion`) to the Debian guest.

### 3. Guest Layer (Debian Chroot)
- The user `ruusian` operates within this isolated but hardware-linked environment.
- Hardware Acceleration is achieved by pointing the Vulkan ICD loader directly at the `freedreno` drivers, utilizing Zink over Turnip to translate OpenGL to Vulkan natively on the Adreno GPU.
- **No Software Rendering**: The environment is strictly configured (`LIBGL_ALWAYS_HW=1`) to fail rather than fallback to CPU rendering, ensuring you always know if acceleration drops.
