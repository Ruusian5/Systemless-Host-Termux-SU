# Audio Stack

> **Generated:** 2026-06-01  
> **Device:** LG G8X (LM-G850) — Android 14  
> **Chroot:** Debian forky/sid

---

## 1. Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│  APPLICATION (Firefox, VLC, XFCE audio apps)              │
│  └─ libpulse-simple.so / libpulse.so                      │
│                                                           │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  DEBIAN CHROOT (guest)                                │ │
│  │  ┌──────────────────────────────────────────────────┐│ │
│  │  │ Protocol: TCP to host :4713                       ││ │
│  │  │ PULSE_SERVER=tcp:127.0.0.1:4713                  ││ │
│  │  └──────────────────────────────────────────────────┘│ │
│  └──────────────────────────────────────────────────────┘ │
│                                                           │
│  ═════════════ Network (localhost TCP) ════════════════   │
│                                                           │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  TERMUX HOST                                          │ │
│  │  ┌──────────────────────────────────────────────────┐│ │
│  │  │ pulseaudio --start                               ││ │
│  │  │ module-native-protocol-tcp port=4713              ││ │
│  │  │ auth-anonymous=1 auth-ip-acl=127.0.0.1           ││ │
│  │  └──────────────────────────────────────────────────┘│ │
│  │                                                       │ │
│  │  ┌──────────────────────────────────────────────────┐│ │
│  │  │ Android Audio Flinger (ALSA path)                ││ │
│  │  └──────────────────────────────────────────────────┘│ │
│  └──────────────────────────────────────────────────────┘ │
│                                                           │
│  ANDROID AUDIO HAL (Hardware)                             │
│  └─ Qualcomm WCD934x Audio Codec                          │
└──────────────────────────────────────────────────────────┘
```

---

## 2. Audio Components

### 2.1 Host (Termux)

| Component | Detail |
|-----------|--------|
| Package | `pulseaudio` 17.0-1 (stable) |
| Binary | `/data/data/com.termux/files/usr/bin/pulseaudio` |
| Version | `pulseaudio 17.0-dirty` |
| Start method | `pulseaudio --start` |
| TCP module | `module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1` |
| Port | 4713 (localhost only) |

### 2.2 Guest (Debian chroot)

| Component | Detail |
|-----------|--------|
| Package | `pulseaudio`, `pulseaudio-utils` |
| Connection | `PULSE_SERVER=tcp:127.0.0.1:4713` |
| Config | `/etc/pulse/default.pa` (standard Debian config) |
| Client config | `/etc/pulse/client.conf` (standard) |
| Mic module | `/etc/pulse/default.pa.d/mic.pa` → `load-module module-sles-source` |

### 2.3 Audio Path (from chroot perspective)

```
Application → libpulse → TCP :4713 → host pulseaudio → Android ALSA → hardware
```

---

## 3. Socket / Runtime

### 3.1 PulseAudio Socket (Host)

The PulseAudio server on the host creates an abstract socket:
- `pulse/native` in `$TMPDIR` (`/data/data/com.termux/files/usr/tmp/pulse/`)

**No Unix socket sharing** — the chroot connects via TCP instead of sharing the Unix socket.

### 3.2 PulseAudio Module Configuration

```bash
# Loaded by startxfce4_chrootDebian.sh:
pactl load-module module-native-protocol-tcp \
  port=4713 \
  auth-anonymous=1 \
  auth-ip-acl=127.0.0.1
```

**Security:** Authentication is disabled (`auth-anonymous=1`) and restricted to localhost (`auth-ip-acl=127.0.0.1`).

---

## 4. Known Issues

| Issue | Cause | Impact |
|-------|-------|--------|
| Chroot can't find PulseAudio | Host PulseAudio not started | Retry loop: "Disconnected... attempting to reconnect in 5 seconds" |
| No ALSA inside chroot | ALSA not configured for chroot | All audio must go through PulseAudio |
| D-Bus failure prevents audio | PulseAudio may require D-Bus for some features | Basic audio works without D-Bus |

---

## 5. ALSA Configuration

ALSA is **not configured** inside the chroot. All audio goes through PulseAudio.

No `/etc/asound.conf` or `~/.asoundrc` present.

---

## 6. Microphone (SLES Source)

The chroot has a custom PulseAudio module configuration for microphone input:

```bash
# /etc/pulse/default.pa.d/mic.pa
load-module module-sles-source
```

This loads the **SLES source module** which interfaces with Android's audio input system, enabling microphone access from inside the chroot.

---

## 7. Testing Audio

### From inside chroot:
```bash
# Test basic playback
paplay /usr/share/sounds/alsa/Front_Center.wav

# List sinks
pactl list sinks short

# Check connection
pactl info
# → Server String: tcp:127.0.0.1:4713
```

### From host (Termux):
```bash
# Test host PulseAudio is running
pulseaudio --start
pactl info

# Verify TCP module
pactl list modules | grep native-protocol-tcp
```

---

## 8. Troubleshooting

### Symptom: "Disconnected from PulseAudio server"

**Cause:** Host PulseAudio not running or TCP module not loaded.

**Fix:**
```bash
# On host (Termux):
pulseaudio --start
sleep 2
pactl load-module module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1
```

### Symptom: No audio output

**Cause:** Application not connecting to PulseAudio server.

**Fix:** Verify `PULSE_SERVER=tcp:127.0.0.1:4713` is set in the application's environment.
