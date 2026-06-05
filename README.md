# Systemless-Host-Termux-SU

> **Pro Workstation Edition v0.1 (Hardened)**  
> Transform a rooted Android device into a production-grade Linux workstation via Termux + Debian chroot.

---

## Overview

This project creates a **full Linux desktop environment** on an Android phone/tablet without replacing the host OS. It uses:

- **Termux** as the host runtime
- **MagiskSU** for root access
- **Debian chroot** for the Linux userspace
- **Termux:X11** for display forwarding
- **Zink + Turnip (Freedreno)** for GPU acceleration
- **PulseAudio** for audio bridging

---

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    APPLICATIONS                           │
│  XFCE4  │  Firefox  │  Terminal  │  VLC  │  Thunar      │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│              DEBIAN CHROOT (Guest)                        │
│  /data/local/tmp/chrootDebian                             │
│                                                           │
│  • Debian forky/sid (testing)                             │
│  • XFCE4 desktop                                         │
│  • Mesa (Zink + Turnip Vulkan)                            │
│  • PulseAudio client (TCP to host)                        │
│  • Firefox ESR / Firefox                                  │
│  • D-Bus session                                          │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│              KERNEL BRIDGE (mount-debian.sh)               │
│                                                           │
│  • /dev, /proc, /sys bind mounts                         │
│  • /dev/kgsl-3d0 (GPU)                                   │
│  • /dev/dri/* (DRM)                                      │
│  • /dev/urandom, /dev/shm                                │
│  • /sdcard (file access)                                 │
│  • Termux $TMPDIR/.X11-unix (X11 socket bridge)          │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│              TERMUX (Host)                                │
│                                                           │
│  • Termux:X11 (display server)                            │
│  • PulseAudio (audio server)                              │
│  • VirGL (GPU bridge, fallback)                           │
│  • clipboard-sync (bidirectional clipboard)               │
│  • OpenSSH / socat                                        │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│              ANDROID + MAGISK                             │
│                                                           │
│  • Android 14 (API 34)                                    │
│  • Magisk 30.7 (root)                                     │
│  • Kernel 4.14.355                                        │
│  • Adreno 640 GPU (Snapdragon 855)                        │
│  • 5.3 GB RAM / 100 GB storage                           │
└──────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
Systemless-Host-Termux-SU/
├── install.sh                 # Automated installer
├── validate.sh                # Validation gate (CI)
├── scripts/                   # Host-side operational scripts
│   ├── cmds.sh               # Dashboard (static menu)
│   ├── mount-debian.sh       # Kernel bridge (bind mounts)
│   ├── startxfce4_chrootDebian.sh  # GUI session launcher
│   ├── stop-debian.sh        # Graceful shutdown
│   ├── cli-bridge.sh         # CLI TTY allocator
│   ├── clipboard-sync.sh     # Bidirectional clipboard daemon
│   ├── gpu-check.sh          # GPU diagnostic (read-only)
│   ├── gpu-audit.sh          # GPU audit + auto-fix
│   ├── repair.sh             # System repair + optimization
│   ├── toggle_res.sh         # Display resolution toggle
│   ├── res.sh                # Resolution wrapper
│   ├── install-tools.sh      # Dev tool installer
│   └── build-custom-mesa.sh  # Mesa driver builder
├── configs/                   # Configuration templates
│   ├── .bashrc               # Host bashrc template
│   ├── .hushlogin            # Login suppression
│   ├── bash_aliases_host     # Host aliases
│   └── debian/               # Debian guest configs
│       ├── etc/profile.d/99-hardware-acceleration.sh
│       ├── home/ruusian/fix_mmap.c
│       └── usr/local/bin/    # Chroot scripts (15 scripts)
├── offline-toolkit/           # Disaster recovery
│   ├── restore.sh            # Full restore from archive
│   ├── update.sh             # Update preserving /home
│   ├── verify.sh             # Archive integrity check
│   ├── create_release.sh     # GitHub release creator
│   └── *.md                  # Backup, migration, recovery docs
├── tests/                     # CI test scripts
│   ├── path_sanity.sh        # Path reference checker
│   └── shellcheck_smoke.sh   # Shell syntax validation
├── tools/                     # Developer utilities
│   ├── offline_pack.sh       # Chroot archive packer
│   └── path_rewrite.sh       # Bulk path rewriter
└── docs/                      # Documentation
    ├── REPOSITORY_MAP.md     # Full file-by-file inventory
    ├── TERMUX_STATE.md       # Termux runtime audit
    ├── DEBIAN_STATE.md       # Debian chroot audit
    ├── GUI_ARCHITECTURE.md   # GUI stack architecture
    ├── GPU_STACK.md          # GPU stack architecture
    ├── AUDIO_STACK.md        # Audio stack architecture
    ├── USER_MODEL.md         # User/UID mapping
    ├── CONFIGURATION_DRIFT.md # Repo vs. runtime comparison
    ├── REFACTOR_PLAN.md      # Reorganization roadmap
    ├── AUDIT_REPORT.md       # Security audit findings
    ├── RECOVERY_GUIDE.md     # Recovery procedures
    ├── TERMUX_X11_GUIDE.md   # X11 troubleshooting
    ├── GPU_ACCELERATION.md   # GPU acceleration guide
    └── ...                    # Other guides
```

---

## Installation

### Prerequisites

- Rooted Android device (Magisk recommended)
- Termux (F-Droid version — **not** Google Play)
- Termux:API (F-Droid)
- Termux:X11 (F-Droid)
- 6 GB free storage
- Debian chroot archive (or let install.sh create one)

### Quick Install

```bash
# Clone the repository
git clone https://github.com/Ruusian5/Systemless-Host-Termux-SU.git
cd Systemless-Host-Termux-SU

# Run the installer
bash install.sh
```

The installer will:
1. Install Termux dependencies (busybox, pulseaudio, mesa, termux-x11, etc.)
2. Copy operational scripts to `$HOME`
3. Inject aliases into `~/.bashrc`
4. Mount the Debian chroot bridges
5. Inside chroot: create user, install packages, compile `fix_mmap.so`

### Manual Setup

See [INSTALL.md](./INSTALL.md) for detailed instructions.

---

## Usage

### Dashboard (Static Menu)

```bash
agy
```

Displays a menu with numbered options. Type the number and press Enter.

| # | Option | Description |
|---|--------|-------------|
| 0 | LAUNCH WORKSTATION (GUI) | Start XFCE desktop via Termux:X11 |
| 1 | ENTER LINUX TERMINAL (CLI) | Interactive Debian shell |
| 2 | GPU/VULKAN DIAGNOSTIC | Read-only GPU status check |
| 3 | SYSTEM REPAIR & CLEANUP | Fix packages, caches, governors |
| 4 | DEBIAN DEV TOOL INSTALLER | Install VS Code, Chromium, etc. |
| 5 | CUSTOM MESA DRIVER BUILD | Compile Mesa from source |
| 6-8 | POWER PROFILES | Performance / Balanced / Cooldown |
| 9 | RESET KERNEL BRIDGES | Re-mount chroot bridges |
| 10 | GPU STACK AUDIT & AUTO-FIX | Deep GPU inspection + fix |
| 11 | DEBIAN MAINTENANCE (UPDATE) | apt update + upgrade |
| 12 | FULL SYSTEM SHUTDOWN | Stop Debian + unmount bridges |
| 13 | TOGGLE RESOLUTION | Switch phone ↔ HDMI mode |

### Aliases

| Alias | Action |
|-------|--------|
| `agy` | Launch dashboard |
| `fix` | System repair (option 3) |
| `power` | Performance mode (option 6) |
| `balanced` | Balanced mode (option 7) |
| `cool` | Cooldown mode (option 8) |
| `gpu` | GPU diagnostic (option 2) |
| `deb` | Enter Debian CLI (option 1) |
| `res` | Toggle resolution (option 13) |
| `sd` | Shutdown (option 12) |

### Quick Start (Full Desktop)

```bash
# From a fresh Termux session:
bash ~/mount-debian.sh    # Mount kernel bridges (one-time)
agy                       # Launch dashboard
# → Select [0] LAUNCH WORKSTATION (GUI)
```

---

## Boot Process

```
Termux launch
  → ~/.bashrc (interactive)
    → Auto-mounts chroot (background)
    → Shows dashboard snapshot
  → User types "agy"
    → Static menu displayed
    → Select [0] for GUI
      → startxfce4_chrootDebian.sh
        → Kill stale processes
        → Start PulseAudio (host)
        → Start VirGL bridge
        → Launch Termux:X11
        → Wait for X11 socket
        → Start clipboard sync
        → Mount Debian
        → Chroot → v2-launch.sh → user-session.sh → startxfce4
```

---

## Hardware Support

| Component | Status | Notes |
|-----------|--------|-------|
| Adreno 5xx/6xx | ✅ Full | Zink + Turnip via KGSL |
| Adreno 7xx | ⚠️ Partial | Newer KGSL may differ |
| Mali | ⚠️ Partial | Panfrost ICD available |
| Other GPUs | ⚠️ Limited | llvmpipe fallback |
| Snapdragon 855 | ✅ Reference | Tested on LG G8X |
| Audio (built-in) | ✅ Works | PulseAudio TCP bridge |
| Audio (Bluetooth) | ⚠️ Untested | May need host config |
| Microphone | ✅ Configured | SLES source module |
| Touchscreen | ✅ Works | Android → X11 events |

---

## Known Issues

| Issue | Workaround |
|-------|-----------|
| D-Bus fails in chroot (/tmp perms) | Session bus unavailable; XFCE works without it |
| Black screen with Zink | `xfconf-query -c xfwm4 -p /general/use_compositing -s false` |
| Firefox "No GPUs detected" | Cosmetic only — renders via WebRender+EGL |
| /proc/loadavg not readable | `su -c` needed; dashboard returns "?" without root |
| PulseAudio timeout | Ensure host PulseAudio is started before chroot |
| termux-x11 not running | May be killed by Android; restart session |
| GPU nodes lose permissions | Re-run `bash ~/mount-debian.sh` |

---

## Development

### CI

```bash
bash validate.sh        # Run validation gate
bash tests/shellcheck_smoke.sh  # Shell syntax check
bash tests/path_sanity.sh       # Path reference check
```

### Shell Style

All scripts follow:
- `set -uo pipefail` (but NOT `set -e`)
- bash shebang (`/data/data/com.termux/files/usr/bin/bash`)
- Idempotent operations
- Error messages to stderr
- 2>/dev/null for expected failures

---

## Security

| Risk | Mitigation |
|------|-----------|
| GPU nodes 0666 | Required for chroot access; isolate chroot |
| PulseAudio anonymous | Restricted to localhost (127.0.0.1) |
| Passwordless sudo | Known issue; use strong chroot passwords |
| SELinux enforcing | Termux as untrusted_app — expected |

See [SECURITY.md](./SECURITY.md) and [docs/AUDIT_REPORT.md](./docs/AUDIT_REPORT.md).

---

## License

MIT — Copyright (c) 2026 Ruusian5

---

## Project Status

**v0.1 (Hardened Enterprise Release)** — All core features functional. Documentation in progress. See [ROADMAP.md](./ROADMAP.md) for future plans.
