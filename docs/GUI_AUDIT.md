# GUI Audit

Generated: 2026-06-03

## Environment

- Host: Android (rooted), Termux
- Linux: Debian bookworm (chroot at /data/local/tmp/chrootDebian)
- Display: Termux:X11 on :0
- Desktop: XFCE 4.18
- Window Manager: xfwm4 with compositor
- Panel: xfce4-panel (dual panel layout)
- Session Controller: v2-launch.sh V18 (direct component manager, no xfce4-session)

## Running Components

### XFCE Session (all run as root — CRITICAL)

| Component | PID | User | Status |
|-----------|-----|------|--------|
| xfwm4 --compositor=on | 25012 | **root** | Running |
| xfce4-panel | 25024 | **root** | Running |
| xfdesktop | 25035 | **root** | Running |
| xfsettingsd | 24983 | **root** | Running |
| xscreensaver | 25071 | **root** | Running |
| xfce4-notifyd | 25230 | **root** | Running |
| xfconfd | 24901 | **root** | Running |
| at-spi-bus-launcher | 24935 | **root** | Running |
| gvfsd family | 24959+ | **root** | Running |

### Infrastructure

| Component | PID | User | Status |
|-----------|-----|------|--------|
| termux-x11 :0 | 24591 | termux | Running |
| PulseAudio (host) | 24558 | termux | Running |
| dbus-daemon --system | new per session | root | Running |
| dbus-daemon --session | 24887 | **root** | Running |
| com.termux.x11 (Android) | 24593 | 10572 | Running |

## What Works

- XFCE panel with all plugins (whiskermenu, tasklist, cpugraph, systray, pulseaudio, clock, actions, weather)
- Compositor (xfwm4 --compositor=on, confirmed via xfconf-query: `true`)
- xfdesktop (desktop icons)
- xscreensaver (running, configured 5min timeout)
- Notifications (xfce4-notifyd)
- GPU graph, weather, systray, pulseaudio panel plugins
- Dual panel layout (bottom panel + top dock)
- Firefox (via runuser wrapper)
- VLC (via runuser wrapper, just created)

## What Is Broken / Wrong

### CRITICAL: All GUI runs as root
Every XFCE process, dbus session, and infrastructure process runs as root.
This causes:
- VLC hard-refuses to run as root (requires per-app runuser wrapper)
- Firefox requires runuser wrapper
- DBUS_SESSION_BUS_ADDRESS not propagated to normal user
- File permissions may be wrong for user files
- Thunar, Terminal, Settings all run as root

### Session bus owned by root
dbus-daemon --session runs as root. Socket at /run/user/1000/bus is root-owned.
When ruusian processes try to connect, they get "Connection refused" or "Permission denied".
The env var DBUS_SESSION_BUS_ADDRESS is empty for ruusian.

### picom.desktop still present
/usr/share/applications/picom.desktop references picom, which was removed.
Should be removed or hidden.

### firefox-launcher.desktop in ~/.local/share/applications
This is a user-local duplicate of firefox-esr.desktop.
Creates a second "Firefox" entry in the menu.

### Way too many watchdog sleep 30 processes
Every restart of v2-launch.sh leaves orphan sleep 30 processes.
Currently 7+ stale sleep processes.

### No XFCE session management
~/.cache/sessions/ is empty. No session restore.
Session logout/shutdown commands will fail (they call xfce4-session-logout which needs xfce4-session).

### user-session.sh v6 is stale
Still references picom and xfce4-session. Not used by V18.

### XFCE env vars incomplete for ruusian
DBUS_SESSION_BUS_ADDRESS= (empty)
XDG_SESSION_TYPE= (empty)
XDG_CURRENT_DESKTOP= (empty)

## Launcher Inventory

### /usr/share/applications (41 entries)
All standard XFCE entries plus:
- firefox-esr.desktop → firefox-launcher %u ✓
- vlc.desktop → vlc-launcher --started-from-file %U ✓ (just fixed)
- picom.desktop → picom **DEAD** (picom removed)
- mpv.desktop → mpv
- pavucontrol.desktop → pavucontrol

### ~/Desktop (4 entries)
- terminal.desktop → xfce4-terminal
- thunar.desktop → thunar %u
- settings.desktop → xfce4-settings-manager
- gpu-info.desktop → vulkaninfo/glxinfo (runs as root)

### ~/.local/share/applications (1 entry)
- firefox-launcher.desktop → DUPLICATE of firefox-esr.desktop

## Display
- Resolution: managed by toggle_res.sh / cmds.sh res
- Compositor: xfwm4 native (on)
- No picom, no xcompmgr

## Session Ownership Issues
| Application | Runs As | Should Run As | Fix Method |
|------------|---------|---------------|------------|
| xfwm4 | root | ruusian | runuser in v2-launch.sh |
| xfce4-panel | root | ruusian | runuser in v2-launch.sh |
| xfdesktop | root | ruusian | runuser in v2-launch.sh |
| xfsettingsd | root | ruusian | runuser in v2-launch.sh |
| xscreensaver | root | ruusian | runuser in v2-launch.sh |
| xfce4-notifyd | root | ruusian | runuser in v2-launch.sh |
| xfce4-terminal | root | ruusian | Via launcher |
| thunar | root | ruusian | Via launcher |
| Firefox | ruusian ✓ | ruusian | runuser wrapper (works) |
| VLC | ruusian ✓ | ruusian | runuser wrapper (just fixed) |
