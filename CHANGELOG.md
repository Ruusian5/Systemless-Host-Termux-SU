# 🔄 Changelog

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
