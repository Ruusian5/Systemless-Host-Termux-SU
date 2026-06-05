# GUI Architecture

> **Generated:** 2026-06-01  
> **Device:** LG G8X (LM-G850) — Android 14 — Kernel 4.14.355  
> **Chroot:** `/data/local/tmp/chrootDebian` — Debian forky/sid

---

## 1. Overview

The GUI stack is a **4-layer pipeline**:

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 4: Applications (XFCE, Firefox, Terminal, VLC)       │
│  ───────────── Debian chroot (guest) ─────────────────────  │
│  LAYER 3: Display Server / Compositor (Xorg, XFWM4)         │
│  ───────────── Termux (host) ─────────────────────────────  │
│  LAYER 2: X11 Forwarding (Termux:X11)                       │
│  LAYER 1: Android SurfaceFlinger / Hardware Composer        │
└─────────────────────────────────────────────────────────────┘
```

Each layer handles a specific responsibility:

| Layer | Location | Component | Role |
|-------|----------|-----------|------|
| 1 | Android System | SurfaceFlinger | Physical display, touch input |
| 2 | Termux (host) | Termux:X11 + VirGL | X11 server, GPU bridge |
| 3 | Debian (guest) | Xorg | X display server, window management |
| 4 | Debian (guest) | XFCE4 / Firefox / etc. | Desktop environment, applications |

---

## 2. Startup Flow (Detailed)

### 2.1 Entry Point: `startxfce4_chrootDebian.sh`

**Triggered by:** Dashboard option [0] (`run_selection 0`) or alias `bash ~/startxfce4_chrootDebian.sh`

**Step-by-step execution:**

```
Step 1: Terminate stale processes
  ├─ pkill -15 termux-x11 pulseaudio virgl_test_server clipboard-sync
  └─ sleep 1

Step 2: Clean up old sockets
  ├─ rm -f $TMPDIR/.X11-unix/X0
  ├─ rm -f $TMPDIR/.X0-lock
  └─ rm -f $TMPDIR/.virgl_test

Step 3: Start PulseAudio (host)
  ├─ pulseaudio --start
  ├─ Wait 2s
  └─ pactl load-module module-native-protocol-tcp port=4713 auth-anonymous=1

Step 4: Start VirGL GPU bridge (host)
  ├─ virgl_test_server_android --multi-clients &
  └─ Wait 1s

Step 5: Start Termux:X11 (Android app)
  ├─ am start com.termux.x11
  ├─ termux-x11 :0 -ac -legacy-drawing &
  └─ Wait up to 20s for X0 socket to appear

Step 6: Start clipboard sync daemon
  └─ bash clipboard-sync.sh &

Step 7: Mount Debian bridges
  └─ bash mount-debian.sh (idempotent, checks before mounting)

Step 8: Launch Debian session controller
  └─ su -c "busybox chroot $DEBIANPATH /usr/local/bin/v2-launch.sh"
```

### 2.2 Chroot Session Controller: `v2-launch.sh`

**Inside chroot, as root:**

```
Step 1: Source hardware acceleration profile
  └─ . /etc/profile.d/99-hardware-acceleration.sh

Step 2: Start system D-Bus daemon
  ├─ mkdir -p /run/dbus
  └─ dbus-daemon --system --fork

Step 3: Create user runtime directory
  ├─ mkdir -p /run/user/1000
  └─ chown 1000:1000 /run/user/1000

Step 4: Switch to user ruusian and launch session
  └─ su -l ruusian -c /usr/local/bin/user-session.sh
```

### 2.3 User Session: `user-session.sh`

**Inside chroot, as ruusian:**

```
Step 1: Source hardware acceleration profile
  └─ . /etc/profile.d/99-hardware-acceleration.sh

Step 2: Start D-Bus user session
  ├─ eval $(dbus-launch --sh-syntax)
  └─ export DBUS_SESSION_BUS_ADDRESS

Step 3: Disable XFWM4 compositing
  └─ xfconf-query -c xfwm4 -p /general/use_compositing -s false
      (Prevents black screen with Zink GPU driver)

Step 4: Start XFCE4 desktop
  └─ exec startxfce4
```

---

## 3. Environment Variables

### 3.1 Critical Display Variables

| Variable | Value | Source | Purpose |
|----------|-------|--------|---------|
| `DISPLAY` | `:0` | `99-hardware-acceleration.sh` | X11 display number |
| `XAUTHORITY` | (unset) | — | X authority file (not used) |
| `WAYLAND_DISPLAY` | (unset) | — | Wayland not used |

### 3.2 Hardware Acceleration Variables

Set in `/etc/profile.d/99-hardware-acceleration.sh` (sourced by both v2-launch.sh and user-session.sh):

| Variable | Value | Purpose |
|----------|-------|---------|
| `VK_ICD_FILENAMES` | `/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json` | Select Turnip Vulkan driver |
| `TU_DEBUG` | `kgsl,noconform` | Enable KGSL backend, disable Vulkan conformance checks |
| `GALLIUM_DRIVER` | `zink` | Force Zink (OpenGL-over-Vulkan) |
| `MESA_LOADER_DRIVER_OVERRIDE` | `zink` | Force Mesa to load Zink driver |
| `LIBGL_ALWAYS_HW` | `1` | Prevent software fallback |
| `LIBGL_ALWAYS_SOFTWARE` | `0` | Prevent software fallback |
| `MESA_GL_VERSION_OVERRIDE` | `4.6` | Advertise OpenGL 4.6 capability |
| `MESA_GLSL_VERSION_OVERRIDE` | `460` | Advertise GLSL 460 capability |
| `MOZ_X11_EGL` | `1` | Enable EGL in Firefox/X11 |

### 3.3 Audio Variables

| Variable | Value | Source | Purpose |
|----------|-------|--------|---------|
| `PULSE_SERVER` | `tcp:127.0.0.1:4713` | `.bashrc` / `firefox-launcher` | Connect to host PulseAudio |

### 3.4 Runtime Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `XDG_RUNTIME_DIR` | `/run/user/1000` | Per-user runtime files (D-Bus socket, PulseAudio socket) |

---

## 4. Session Flow (Runtime Architecture)

### 4.1 Process Tree (Running Session)

```
Termux (host)
  ├─ bash startxfce4_chrootDebian.sh (PID: parent)
  │   ├─ pulseaudio --start
  │   ├─ virgl_test_server_android (GPU bridge daemon)
  │   ├─ termux-x11 :0 (X11 server, Android app)
  │   ├─ bash clipboard-sync.sh (bidirectional clipboard)
  │   └─ su -c busybox chroot ... v2-launch.sh
  │       └─ chroot:
  │           ├─ dbus-daemon --system (PID 1 inside chroot)
  │           ├─ su -l ruusian -c user-session.sh
  │           │   ├─ dbus-daemon (user session, as ruusian)
  │           │   ├─ xfce4-session
  │           │   │   ├─ xfwm4 (window manager)
  │           │   │   ├─ xfce4-panel
  │           │   │   ├─ Thunar (file manager)
  │           │   │   ├─ xfdesktop (desktop manager)
  │           │   │   └─ ... XFCE components
  │           │   └─ firefox (when launched)
  │           └─ (login shells for CLI)
```

### 4.2 X11 Forwarding Architecture

```
Debian App (e.g., Firefox)
  → X11 client library (libX11.so)
  → Unix socket /tmp/.X11-unix/X0   (inside chroot)
  → Bind mount to Termux $TMPDIR/.X11-unix/X0
  → Termux:X11 server process
  → Android SurfaceFlinger
  → Physical Display
```

**Note:** The X11 socket bridge uses the mount-debian.sh bind mount:
```
$TMPDIR/.X11-unix/  →  chroot/tmp/.X11-unix/
```
This allows the chroot X11 clients to communicate with the Termux:X11 server without a TCP connection.

### 4.3 Input Flow

```
Android Touch/Keyboard
  → Android Input System
  → Termux:X11 (translates Android events to X11)
  → X11 Unix socket
  → Xorg inside chroot
  → XFCE / Applications
```

---

## 5. GPU Rendering Path

See also: [GPU_STACK.md](./GPU_STACK.md)

### 5.1 Primary Path (Zink + Turnip + KGSL)

```
Application (OpenGL call)
  → Mesa Gallium (Zink driver — translates GL to Vulkan)
  → Mesa Vulkan (Turnip driver — translates Vulkan to KGSL)
  → KGSL kernel interface (/dev/kgsl-3d0)
  → Adreno 640 GPU hardware
```

### 5.2 Alternative Path (VirGL — for non-Adreno or testing)

```
Application (OpenGL call)
  → Mesa Gallium (VirGL driver)
  → Unix socket .virgl_test
  → Host virgl_test_server_android
  → Host Mesa (Freedreno)
  → KGSL kernel interface
  → Adreno 640
```

**Current configuration:** Zink path is preferred. VirGL is disabled but available as fallback (commented out in hardware profile).

---

## 6. Clipboard Flow

```
Android clipboard (termux-clipboard-get/set)
  ↔ clipboard-sync.sh daemon (runs on host, polls every 1s)
  ↔ X11 clipboard (xclip inside chroot via chroot CLI)
```

**Bidirectional:** Changes on either side propagate within 1 second.

---

## 7. Known Issues

| Issue | Root Cause | Impact |
|-------|-----------|--------|
| D-Bus fails to start | `/tmp` permissions in Android | Session bus unavailable, some XFCE features degraded |
| Black screen with Zink | XFWM4 compositing conflicts with Mesa | Must disable compositing via `xfconf-query` |
| No GPU detection in Firefox | No PCI bus or `/dev/dri/` inside chroot | Firefox reports "No GPUs detected" but still renders |
| Termux:X11 not running | Android may kill background processes | Must restart session |
| PulseAudio connection timeout | Host PulseAudio not started before chroot | Retry logic: reconnects every 5s |

---

## 8. Recovery Procedures

### Black Screen (GPU crash)
```bash
# Inside chroot:
xfconf-query -c xfwm4 -p /general/use_compositing -s false
xfce4-panel -r
xfwm4 --replace
```

### Termux:X11 crash
```bash
# On host:
am start com.termux.x11
termux-x11 :0 -ac -legacy-drawing &
```

### Clipboard sync failure
```bash
# On host:
pkill -f clipboard-sync
bash ~/scripts/clipboard-sync.sh &
```
