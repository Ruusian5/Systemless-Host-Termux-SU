# Systemless-Host-Termux-SU (Pro Workstation Edition)

A high-performance, hardware-accelerated Debian chroot environment for Android/Termux, optimized for absolute stability and raw GPU access.

## 🚀 Core Architecture & Recent Upgrades (v15.x)

This project bridges the gap between Android's isolated environment and a full Linux workstation. Recent architectural overhauls by a senior developer have resolved critical kernel limitations and state management issues.

### 1. Kernel Bug Bypass & Memory Fix (`fix_mmap.so`)
Older custom Android kernels (e.g., Linux 4.14) contain a fatal bug in the `close_range` system call, causing modern Debian processes to get permanently stuck in uninterruptible kernel loops (100% CPU lockups).
- **The Fix:** A custom C library (`fix_mmap.c`) is injected globally via `LD_PRELOAD`. It intercepts `close_range` and safely returns `ENOSYS`, forcing glibc to fallback to safe, manual file descriptor closures. It also intercepts `mmap` calls exceeding the 39-bit address limit, preventing immediate segmentation faults.

### 2. D-Bus & Compositing Race Condition Fix (`user-session.sh`)
When combining `Zink` + `Turnip` (Vulkan) hardware acceleration with Termux:X11, attempting to use the XFCE compositor causes a DRI3 negotiation failure, resulting in a black screen.
- **The Fix:** `user-session.sh` strictly initializes the D-Bus daemon (`dbus-launch --sh-syntax`) *before* executing `xfconf-query`. This ensures compositing is successfully disabled at the system level before `xfwm4` starts, granting full 2D stability while retaining 3D hardware acceleration for applications.

### 3. Idempotent State Management (`mount-debian.sh`)
- **The Fix:** The mount script no longer relies on a single point of failure (e.g., checking if `/dev` exists). Instead, it uses custom `domount` and `dotmpfs` functions to read `/proc/mounts` line-by-line, mounting only the specific bridges that are missing. This guarantees a safe, idempotent execution that recovers perfectly from partial crashes.

### 4. Graceful Process Lifecycle (`stop-debian.sh`)
- **The Fix:** Shutdowns now follow strict POSIX compliance. `SIGTERM` (-15) is issued to all GUI and DBus processes, followed by a `sleep`, allowing applications to cleanly release sockets and locks. `SIGKILL` (-9) is only used as a final fallback. Additionally, `am force-stop com.termux.x11` is invoked to destroy the Android app's background state, completely preventing stale socket connection errors (black screens) on the next launch.

### 5. Hardware Acceleration Pipeline (`99-hardware-acceleration.sh`)
- Exposes raw Vulkan and OpenGL capabilities to the chroot using Mesa `Zink` and the `Turnip` KGSL driver for Adreno GPUs (e.g., Adreno 640).

## 🛠️ Usage

**Launch the Interactive Dashboard:**
```bash
bash ~/cmds.sh
```
*(Optionally aliased as `agy` in your `.bashrc`)*

**Manual Start/Stop:**
- Start: `bash ~/startxfce4_chrootDebian.sh`
- Stop: `bash ~/stop-debian.sh`
