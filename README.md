# Systemless-Host-Termux-SU

Enterprise Debian 12 Workstation running natively inside a chroot on rooted Android (LG G8, Snapdragon 855, Adreno 640). XFCE desktop via Termux:X11, PulseAudio over TCP, hardware-accelerated GPU (**Turnip + Zink**, no VirGL).

---

## Hardware Platform

| Component | Detail |
|-----------|--------|
| Device | LG G8 (LM-G850) |
| SoC | Snapdragon 855 (msmnile) |
| GPU | Adreno 640 (`/dev/kgsl-3d0`, `/dev/dri/card0`, `/dev/dri/renderD128`) |
| RAM | 6 GB |
| Kernel | 4.14.357-Myth-V1 #1 SMP PREEMPT |
| Android | 15 (SDK 35), SELinux Permissive |
| Storage | 100 GB (42 GB free) |

## Architecture

```
Termux Host (Android)
  ├── termux-x11          X11 display server (Android app: Termux:X11)
  ├── pulseaudio           Audio server (TCP bridge port 4713)
  ├── clipboard-sync.sh    Bidirectional clipboard daemon
  ├── cmds.sh              Dashboard TUI (v3.2)  ← main entry point
  └── mount-debian.sh      Bind-mounts /dev, /proc, /sys, /tmp, /sdcard, etc.
       │
       ▼
Debian 12 (bookworm) Chroot at /data/local/tmp/chrootDebian
  ├── XFCE 4 Desktop       xfwm4 + xfdesktop + xfce4-panel + xfsettingsd
  ├── user-session.sh      Session init (dbus, XFCE, dark theme, compositor off)
  ├── v2-launch.sh         Chroot entrypoint (GPU profile, dbus, su to ruusian)
  ├── 99-hardware-acceleration.sh   GPU config (Turnip+Zink, Mesa overrides)
  ├── fix_mmap.so          LD_PRELOAD hack for broken close_range syscall
  ├── Synaptic             GUI package manager (primary software store)
  └── 1,090+ packages      Firefox ESR, Node.js, build-essential, ffmpeg, etc.
```

> **GPU note:** This environment uses **Turnip (Vulkan) + Zink (OpenGL-on-Vulkan)** translation on the Adreno 640. **VirGL is NOT used.** Hardware acceleration works, but the EGL/DRI3 path that GNOME Software relies on is incompatible here (see Known Issues).

## Users

| User | UID | Groups | Shell | Home | sudo password |
|------|-----|--------|-------|------|---------------|
| root | 0 | root | bash | /root | — |
| ruusian | 1000 | sudo,audio,video,input,render,disk,plugdev | bash | /home/ruusian | `1234` |

> **sudo / su inside the chroot** require `/data` to be remounted with `suid` (Android mounts it `nosuid`, which breaks setuid binaries). `mount-debian.sh` and `startxfce4_chrootDebian.sh` perform this remount automatically. If `sudo` ever reports *effective uid is not 0*, re-run dashboard **[3] Mount Chroot** (or **[1] Start GUI**).

## Releases — GPU Drivers & Modifications Bundle

The full Debian rootfs is **not** committed (it is re-downloadable). The non-reinstallable parts are preserved in a single release asset:

- **`releases/gpu-modifications-bundle-20260709.tar.gz`** (~11 MB) — contains the **Turnip + Zink GPU drivers**, our **modifications** (`user-session.sh`, `v2-launch.sh`, `fix_mmap.so`/`.c`, `vk_test`, host dashboard scripts), a **`packages.manifest`** (`dpkg --get-selections` for one-command reinstall), and **`restore.sh`**.

> **Contents are privacy-clean:** no personal files or secrets (`.hermes/`, `.ssh`, `.gnupg`, `.git-credentials`, browser profiles, Documents/Downloads are excluded). See `releases/RESTORE.md` for the full inventory, the **`ruusian` / `1234`** credential note, and the restore procedure.

### Restore onto a fresh Debian rootfs

```bash
tar -xzf releases/gpu-modifications-bundle-20260709.tar.gz -C /
bash releases/mods/restore.sh /data/local/tmp/chrootDebian
```

`restore.sh` installs the GPU drivers, drops in the modifications, creates the `ruusian` user (UID 1000, sudo, password **`1234`**), and replays `packages.manifest` via `dpkg --set-selections` + `apt-get dselect-upgrade`.

## Dashboard (cmds.sh v3.2)

Launch with `bash ~/cmds.sh`. The dashboard shows live status (chroot mount, X11, audio, GPU) and offers:

```
Actions:
  [1]  Start GUI          [2]  Stop GUI          [3]  Mount Chroot
  [4]  Shell root         [5]  Shell ruusian     [6]  Clean & Repair
  [8]  GPU Info           [9]  Synaptic Pkg Mgr  [10] Restart GUI

  [q] Quit   [r] Redraw screen
```

| Option | Script / Action | Notes |
|--------|-----------------|-------|
| [1] Start GUI | `startxfce4_chrootDebian.sh` | Mounts chroot, starts PulseAudio + termux-x11, binds X socket, launches XFCE as `ruusian` |
| [2] Stop GUI | `stop-debian.sh` | Graceful SIGTERM→SIGKILL, then unmounts all bind mounts |
| [3] Mount Chroot | `mount-debian.sh` | Idempotent bind-mounts; **also remounts `/data` with `suid`** so sudo/su work |
| [4] Shell root | inline `busybox chroot` | Root shell inside the chroot |
| [5] Shell ruusian | inline `busybox chroot` → `su -l ruusian` | User shell inside the chroot |
| [6] Clean & Repair | `cleanup.sh` + `repair.sh` | Truncates logs, clears APT cache, `dpkg --configure -a`, `apt-get install -f` |
| [8] GPU Info | `gpu-info.sh` | KGSL model, Turnip driver, Vulkan + Zink/EGL status |
| [9] Synaptic Pkg Mgr | inline `chroot ... synaptic` | Launches the GUI software store on the desktop (see Known Issues) |
| [10] Restart GUI | `stop-debian.sh` + `startxfce4_chrootDebian.sh` | Convenience full restart |

## Scripts Reference

### Termux Host (`~/`)

| Script | Purpose |
|--------|---------|
| `cmds.sh` | Dashboard TUI (v3.2) |
| `startxfce4_chrootDebian.sh` | Full startup: suid remount → mount → X11 → audio → XFCE desktop |
| `stop-debian.sh` | Graceful shutdown: kill processes → unmount all bind mounts |
| `mount-debian.sh` | Bind-mount /dev, /proc, /sys, /tmp, /sdcard, vendor, apex, linkerconfig; remounts `/data` suid |
| `repair.sh` | dpkg fix, apt repair, X11 socket cleanup, fstrim, log truncation |
| `cleanup.sh` | Stale file cleanup, session log truncation, APT cache purge |
| `gpu-info.sh` | Turnip+Zink GPU status reporter |
| `gpu-audit.sh` | GPU stack diagnostic: Adreno, Vulkan, EGL, Mesa, DRI paths |
| `status-diagnostics.sh` | Health report: chroot mounts, X11 socket, audio, logs |
| `fix-audio.sh` | PulseAudio restart with TCP port 4713 + ALSA sink |
| `clipboard-sync.sh` | Bidirectional clipboard (termux-clipboard ↔ xclip inside chroot) |

> The live scripts live in `~/` on the Termux host. The `scripts/` directory in this repo is the canonical copy — keep them in sync (see *Repo & Deploy* below).

### Debian Chroot (`/usr/local/bin/`)

| Script | Purpose |
|--------|---------|
| `v2-launch.sh` | Chroot init: sources GPU profile, starts system dbus, runs user-session |
| `user-session.sh` | XFCE session: lock-file dedup, dbus-launch, starts xfwm4/xfsettingsd/xfdesktop/xfce4-panel/xfce4-power-manager (all guarded by `pgrep` to prevent duplicates) |
| `fix-chroot.sh` | Post-boot fixup: adds groups, creates /run/user/1000, fixes perms |

### Config Files

| Path | Purpose |
|------|---------|
| `/etc/profile.d/99-hardware-acceleration.sh` | GPU env vars: `MESA_LOADER_DRIVER_OVERRIDE=zink`, `VK_ICD_FILENAMES=...freedreno...`, `DISPLAY=:0`, `PULSE_SERVER=tcp:127.0.0.1:4713` |

## Known Issues & Workarounds

| Issue | Workaround |
|-------|------------|
| `close_range` syscall crashes apps | `LD_PRELOAD=/home/ruusian/fix_mmap.so` |
| `sudo`/`su` fail inside chroot ("effective uid is not 0") | `/data` is mounted `nosuid`; re-run **[3] Mount Chroot** (or **[1] Start GUI**) to remount with `suid` |
| **GNOME Software 43.5 will not launch** ("lost connection to rendering server" / DRI3 not capable) | EGL/DRI3 init is incompatible with Turnip+Zink in this X11 setup. **Use Synaptic instead** (dashboard **[9]**, or the Synaptic icon on the desktop). Verified unfixable here. |
| Synaptic launched but shows "no packages" | Run `sudo apt update` first (a shell via dashboard **[5]**, or `apt update` in a terminal). Repos must be indexed before browsing. |
| Stale X11 socket after crash | `stop-debian.sh` auto-cleans, or `rm /data/data/com.termux/files/usr/tmp/.X11-unix/X0` |
| `SESSION_MANAGER=localhost` breaks xfwm4 | `user-session.sh` does `unset SESSION_MANAGER` |
| Duplicate XFCE processes (e.g. two `xfce4-power-manager`) | `user-session.sh` guards each component with `pgrep` before launching |
| Clipboard sync hangs on missing X socket | `clipboard-sync.sh`: `timeout 2` on xclip calls, X11 socket watch with auto-exit on socket loss |
| PulseAudio "Daemon startup failed" | Caused by a stale runtime symlink; remove `~/.config/pulse/*-runtime` then `pulseaudio --start` (dashboard **[1]** handles startup) |

## Repo & Deploy

- `scripts/` — canonical Termux-host scripts (`cmds.sh`, `startxfce4_chrootDebian.sh`, `mount-debian.sh`, `stop-debian.sh`, `cleanup.sh`, `repair.sh`, `gpu-info.sh`, `clipboard-sync.sh`).
- `configs/debian/usr/local/bin/` — chroot-side scripts (`user-session.sh`, `v2-launch.sh`, …) deployed into the chroot at `/usr/local/bin/`.
- `configs/debian/etc/` — chroot config (e.g. `profile.d/99-hardware-acceleration.sh`).

When you edit a host script, update the copy in `scripts/` and vice-versa; the dashboard reads from `~/`, so deploy with `cp scripts/<name>.sh ~/`.

## TODO

### High Priority
- [x] Add `omniroute` exclusion in `stop-debian.sh` (runs inside chroot as ruusian, must not be killed)
- [x] Test `stop-debian.sh` "KILL ALL CHROOT PROCESSES" section to ensure it doesn't kill omniroute
- [ ] Add cleanup of old pip-build-tracker and pip-unpack dirs in /tmp

### Medium
- [ ] Write a regression test suite (bash unit tests for core scripts)
- [ ] Verify Hermes AI Gateway `.env` NVIDIA NIM keys are set

### Low
- [ ] Remove unused scripts: `build-custom-mesa.sh`, `install-tools.sh`, `kill-hogs.sh`
- [ ] Consolidate duplicate configs: `configs/debian/usr/local/bin/` mirrors some chroot scripts

## Recent Changes

| Date | Change |
|------|--------|
| Jul 9 | **Removed App Manager [7]** from dashboard (broken `q` quit loop → infinite "Invalid choice"; required uninstalled `dialog`). Deleted `app-manager.sh` from repo + bundle. Re-audit found source-tree drift: `configs/debian/usr/local/bin/vk_test` and `configs/debian/home/ruusian/fix_mmap.so/.c` were missing (only in `releases/mods/`), so bundle rebuilds silently dropped them — restored both to `configs/` and live chroot, rebuilt privacy-clean **gpu-modifications-bundle-20260709.tar.gz** (Zink+Turnip, vk_test, fix_mmap, no app-manager, no secrets). Verified [1]–[6],[8],[10] run clean. |
| Jul 9 | Full project audit (excluding dpkg manifest + release bundle): fixed 12 host/chroot script issues — `su` authentication failure (chroot `su` missing, `LD_PRELOAD` lost across `su`/`chroot`, `startxfce4` reverted `suid` fix); chroot PATH/term/suid drift; `vk_test` missing; broken dialog `chroot ... which`; `repair.sh` non-idempotent APT; `stop-debian.sh` unmount ordering; `cleanup.sh` secret purge; `app-manager.sh` hardcoded busybox path. Rebuilt privacy-clean **gpu-modifications-bundle-20260709.tar.gz** (Turnip+Zink, LD_PRELOAD wired, battery-monitor + vk_test added, fix_mmap.c present, no secrets). |
| Jul 8 | Dashboard v3.2: added **[9] Synaptic Pkg Mgr** as the GUI software store (GNOME Software is broken on EGL here); **[10] Restart GUI** |
| Jul 8 | Added `app-manager.sh` (terminal package browser) as dashboard **[7]** — later **removed** (broken quit loop, depended on uninstalled `dialog`); package management is via Synaptic [9] or a shell [5] |
| Jul 8 | `mount-debian.sh` & `startxfce4_chrootDebian.sh`: remount `/data` with `suid` so `sudo`/`su` work inside the chroot |
| Jul 8 | `user-session.sh`: `pgrep` guards around all XFCE components to prevent duplicate processes |
| Jul 8 | Removed VirGL; GPU is Turnip+Zink only |
| Jul 6 | Fixed clipboard-sync.sh hangs; restored dashboard; fixed XFCE black screen (`user-session.sh` v3.3) |
| Jul 5 | Full audit of dashboard scripts — 15 issues found, 11 fixed |
| Jun 30 | Initial Debian 12 rootfs deployment |

## Agent Guidelines

If you are an AI agent reading this file:

1. **All commands** in host scripts use `su -c` for root and `busybox chroot /data/local/tmp/chrootDebian` for chroot operations.
2. **Never kill** `omniroute` or `9router` — they run inside the chroot as user `ruusian`.
3. **X11 socket** at `/data/data/com.termux/files/usr/tmp/.X11-unix/X0` must be `srwxrwxrwx`. It only appears after the Termux:X11 Android app connects.
4. **Chroot /tmp** is bind-mounted from host's `$TERMUX_TMP` (same inode).
5. **`pgrep` inside chroot** is BusyBox; use `-x` for exact name match.
6. **GNOME Software is broken here** — never rely on it; use Synaptic (dashboard [9]).
7. **`am`** is at `/system/bin/am` (root-only); use `termux-am` wrapper in Termux context.
8. **Test non-interactive options** with `printf '3\n\nq\n' | timeout 30 bash cmds.sh`.
9. **Keep `~/` and `scripts/` in sync** when editing host-side dashboard scripts.
10. **Git remote:** `git remote set-url origin https://github.com/Ruusian5/Systemless-Host-Termux-SU.git`.
