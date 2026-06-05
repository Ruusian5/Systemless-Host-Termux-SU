# GUI Infrastructure Status (Inventory)
**Date:** 2026-06-05  

## 1. Environment Overview
- **Host:** Termux on Android 14 (LGE LM-G850)
- **Guest:** Debian 12 (Bookworm) arm64 chroot
- **User Account:** `ruusian` (UID 1000, GID 1000)

## 2. GUI Stack Components

| Component | Version/Status |
|-----------|----------------|
| **Desktop Environment** | XFCE 4.18 |
| **Window Manager** | xfwm4 (Compositing: DISABLED) |
| **Display Server** | Termux:X11 (v15) |
| **X11 Display** | `:0` |
| **Mesa Drivers** | 26.0.8 (Zink over Turnip) |
| **Vulkan Status** | ✅ Active (Turnip Adreno 640) |
| **OpenGL Status** | ✅ Active (GL 4.6 Core Profile) |
| **PulseAudio Status** | ✅ Active (tcp:127.0.0.1:4713 bridge) |

## 3. Installed Applications

- **Browsers:** Firefox ESR 140.10.2esr
- **Media Players:** VLC 3.0.23
- **Terminals:** xfce4-terminal
- **File Managers:** Thunar
- **Settings Tools:** xfce4-settings-manager, xfconf-query

## 4. Key Configuration Files

| Scope | Path |
|-------|------|
| **XFCE Config** | `/home/ruusian/.config/xfce4/` |
| **Panel Layout** | `/home/ruusian/.config/xfce4/panel/` |
| **Autostart (User)** | `/home/ruusian/.config/autostart/` |
| **Autostart (System)**| `/etc/xdg/autostart/` |
| **Startup Chain (Host)**| `~/Systemless-Host-Termux-SU/bin/start-gui.sh` |
| **Startup Chain (Guest)**| `/usr/local/bin/v2-launch.sh` |

## 5. Active Services (Watchdog Monitored)
- `xfsettingsd`
- `xfwm4`
- `xfce4-panel`
- `xfdesktop`
- `xscreensaver`
- `dbus-daemon` (System & Session)

---
**Status:** Inventory Complete.
