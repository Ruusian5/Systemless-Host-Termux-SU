# Application Audit

## Desktop Files Cleanup

### Removed
| File | Reason |
|------|--------|
| `/usr/share/applications/picom.desktop` | picom no longer installed (replaced by xfwm4 compositor) |
| `/usr/share/applications/vim.desktop` | vim not installed |
| `~/.local/share/applications/firefox-launcher.desktop` | Duplicate of firefox-esr.desktop |
| `~/Desktop/firefox.desktop` | Duplicate of firefox-esr.desktop (menu showed 2 Firefox entries) |
| `~/.config/xfce4/panel/launcher-*` (4 empty dirs) | Empty launcher stub directories |

### Fixed
| File | Change |
|------|--------|
| `vlc.desktop` | `Exec` now `/usr/bin/vlc` (was `/usr/local/bin/vlc-launcher` with runuser; no longer needed since session runs as ruusian) |

## Session Ownership (V19)

With V19 session controller, all XFCE components and their child processes run as `ruusian` (UID 1000):

- **Panel** (ruusian) → launches all Whisker menu apps as ruusian
- **Desktop** (ruusian) → launches desktop icon apps as ruusian  
- **xfdesktop** (ruusian) → handles desktop icons and wallpaper

This means **no per-app wrappers are needed** for standard GUI apps. The only exception is `firefox-launcher` which sources the GPU acceleration profile and disables sandboxes.

## Launcher Architecture

```
User clicks app in Whisker Menu
  → xfce4-panel (ruusian) reads .desktop file
  → exec() child process (ruusian, inherits UID)
  → Application runs as ruusian ✓
```

## Remaining Issues

- gpu-info.desktop on desktop launches terminal command — works but not critical
- No session management (xfce4-session not used) — logout buttons may not function
