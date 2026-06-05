# Session Ownership Model

## Design

Root prepares the environment; all GUI processes run as `ruusian` (UID 1000).

```
┌──────────────────────────────────────────────────┐
│                    TERMUX                         │
│  ┌────────────────────────────────────────────┐   │
│  │  startxfce4_chrootDebian.sh                │   │
│  │  ├─ pulseaudio (host side, TCP :4713)       │   │
│  │  ├─ termux-x11 :0 -ac                      │   │
│  │  └─ su -c chroot ... v2-launch.sh           │   │
│  └────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│                   CHROOT (root)                   │
│  ┌────────────────────────────────────────────┐   │
│  │  v2-launch.sh (V19)                        │   │
│  │  ├─ dbus-daemon --system (root only)       │   │
│  │  ├─ runuser → dbus-daemon --session        │   │
│  │  ├─ runuser → xfsettingsd                  │   │
│  │  ├─ runuser → xfwm4 --compositor=on        │   │
│  │  ├─ runuser → xfce4-panel                  │   │
│  │  ├─ runuser → xfdesktop                    │   │
│  │  ├─ runuser → xscreensaver                 │   │
│  │  └─ watchdog (respawning as runuser)       │   │
│  └────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│               CHROOT (ruusian)                    │
│  ┌────────────────────────────────────────────┐   │
│  │  All XFCE components                       │   │
│  │  All user apps (launched via whiskermenu)  │   │
│  │  Session dbus                              │   │
│  │                                            │   │
│  │  Launcher wrappers:                        │   │
│  │  ruusian-launcher → any-app                │   │
│  │  firefox-launcher → firefox (sources GPU)  │   │
│  └────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
```

## What Root Owns

- `mount --bind` of /dev, /proc, /sys, X socket, GPU nodes
- System dbus (`/run/dbus/system_bus_socket`)
- Process lifecycle management (watchdog)
- Signal handling (SIGTERM → cleanup)

## What ruusian Owns

- D-Bus session bus (`/run/user/1000/bus`)
- XFCE desktop environment (all components)
- All user applications
- File manager, terminal, browser, media player
- Panel, compositor, screensaver
- Wallpaper, theme settings

## Launcher Architecture

### ruusian-launcher (generic)
```
/usr/local/bin/ruusian-launcher <app> [args]
```
Sets DISPLAY, PULSE_SERVER, XDG_RUNTIME_DIR, DBUS_SESSION_BUS_ADDRESS
then `exec runuser -u ruusian -g ruusian -p -- <app> [args]`

Used by: vlc.desktop, and other apps via desktop Exec rewrite.

### firefox-launcher (Firefox-specific)
```
/usr/local/bin/firefox-launcher [args]
```
Same as ruusian-launcher but additionally:
- Sources `/etc/profile.d/99-hardware-acceleration.sh`
- Sets all MOZ_DISABLE_*_SANDBOX=1 (required for chroot)

### Direct runuser in v2-launch.sh
XFCE core components launched directly via `runuser -u ruusian -g ruusian -p -- <cmd>`
inside the session controller, not via launcher scripts.

## DBUS Model

- **System bus**: Root-owned, started early in v2-launch.sh. Used for hardware events, network manager.
- **Session bus**: ruusian-owned, started via `runuser`. Socket at `/run/user/1000/bus`. All user apps connect here.
- **at-spi bus**: Accessibility bus, started as ruusian via the session bus activation.

## X11 Model

- **X server**: termux-x11 running in Termux (user 10569), not inside chroot
- **X socket**: Bind-mounted from Termux `/tmp/.X11-unix/X0` → chroot `/tmp/.X11-unix/X0`
- **Permissions**: Socket set world-accessible (chmod 777) for ruusian to connect
- **Compositor**: xfwm4 native (`--compositor=on`), runs as ruusian

## Privilege Separation Benefits

| Component | Before (V18) | After (V19) |
|-----------|-------------|-------------|
| xfwm4 | root | ruusian |
| xfce4-panel | root | ruusian |
| xfdesktop | root | ruusian |
| xfsettingsd | root | ruusian |
| xscreensaver | root | ruusian |
| D-Bus session | root | ruusian |
| xfce4-notifyd | root | ruusian |
| gvfs family | root | ruusian |
| at-spi | root | ruusian |
| Firefox | ruusian (wrapper) | ruusian (direct) |
| VLC | ruusian (wrapper) | ruusian (direct) |
| Thunar | root | ruusian |
| Terminal | root | ruusian |
| Settings | root | ruusian |
