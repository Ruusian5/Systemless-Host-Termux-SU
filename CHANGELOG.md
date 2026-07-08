# 🔄 Changelog

## [v3.2] - 2026-07-08 (Dashboard & Software Manager)

### Added
- **Synaptic** as the primary GUI software manager (dashboard **[9]**). GNOME Software 43.5 is incompatible with Turnip+Zink EGL/DRI3 in this X11 setup and does not launch.
- **App Manager** (`app-manager.sh`) — terminal package browser with categories, install/remove/update/search (dashboard **[7]**).
- **[10] Restart GUI** convenience option (stop + start).

### Changed
- **Removed VirGL**; GPU is now **Turnip + Zink** only.
- `mount-debian.sh` and `startxfce4_chrootDebian.sh` now remount `/data` with `suid` so `sudo`/`su` work inside the chroot (Android mounts `/data nosuid`).
- `user-session.sh` guards every XFCE component (xfwm4, xfsettingsd, xfdesktop, xfce4-panel, xfce4-power-manager) with `pgrep` to prevent duplicate processes.
- Dashboard status line now reports chroot mount, X11, audio, and GPU state live.

### Known Issues
- GNOME Software 43.5 crashes on EGL/DRI3 init ("lost connection to rendering server") — unfixable in this environment; use Synaptic.

## [v0.1.0] - 2026-05-31 (Hardened Enterprise Release)

### Added
- Advanced TUI Dashboard (`agy`) for system vitals.
- Enterprise-grade kernel bridge with automated SUID remount logic.
- Zink + Turnip GPU Acceleration hooks for Adreno 640.
- Pre-configured Firefox ESR with uBlock Origin and hardware decoding.
- Pre-configured VLC Media Player with `gles2` output hooks.
- Automated Debian package maintenance and cache cleaning tools.
- Strict hardware-only rendering policies (`LIBGL_ALWAYS_HW=1`).

### Changed
- All shell scripts refactored with `set -euo pipefail` for reliability.
- Migrated from raw `su -c` strings to idempotent temporary execution scripts to prevent shell injection.
- Replaced aggressive process killing with graceful SIGTERM -> SIGKILL lifecycles.
- Upgraded Debian guest Mesa drivers to the latest versions from `sid` for modern Vulkan support.
