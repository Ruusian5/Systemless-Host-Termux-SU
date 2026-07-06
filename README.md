# Systemless-Host-Termux-SU

Enterprise Debian 12 Workstation running natively inside a chroot on rooted Android (LG G8, Snapdragon 855, Adreno 640). XFCE desktop via Termux:X11, PulseAudio over TCP, hardware-accelerated GPU (virgl/Zink).

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
  ├── pulseaudio           Audio server (OpenSL ES sink)
  ├── clipboard-sync.sh    Bidirectional clipboard daemon
  ├── virgl_test_server    VirGL GPU acceleration bridge
  ├── cmds.sh              Dashboard TUI (v2.1)
  └── mount-debian.sh      Bind-mounts /dev, /proc, /sys, /tmp, /sdcard, etc.
       │
       ▼
Debian 12 (bookworm) Chroot at /data/local/tmp/chrootDebian
  ├── XFCE 4 Desktop       xfwm4 + xfdesktop + xfce4-panel + xfsettingsd
  ├── user-session.sh      Session init (dbus, XFCE, dark theme, compositor off)
  ├── v2-launch.sh         Chroot entrypoint (GPU profile, dbus, su to ruusian)
  ├── 99-hardware-acceleration.sh   GPU config (virpipe, Mesa overrides)
  ├── fix_mmap.so          LD_PRELOAD hack for broken close_range syscall
  ├── Hermes AI Gateway    (Nous Research agent)
  └── 1,090 packages       Firefox ESR, Node.js, build-essential, ffmpeg, etc.
```

## Users

| User | UID | Groups | Shell | Home |
|------|-----|--------|-------|------|
| root | 0 | root | bash | /root |
| ruusian | 1000 | sudo,audio,video,input,render,disk,plugdev | bash | /home/ruusian |

## Dashboard (cmds.sh v2.1)

```
Quick Actions:
  [1] Start GUI Desktop     [2] Stop GUI
  [3] Mount Chroot          [4] System Repair
  [5] GPU Audit             [6] Audio Restart/Fix
  [7] Status Diagnostics

Shell Access:
  [8] Login as root         [9] Login as ruusian

Utilities:
  [10] Clipboard Sync       [11] Clear System Cache
  [12] Cleanup System
```

## Scripts Reference

### Termux Host (`~/`)

| Script | Purpose |
|--------|---------|
| `cmds.sh` | Dashboard TUI |
| `startxfce4_chrootDebian.sh` | Full startup: mount → X11 → audio → XFCE desktop |
| `stop-debian.sh` | Graceful shutdown: kill processes → unmount all bind mounts |
| `mount-debian.sh` | Bind-mount /dev, /proc, /sys, /tmp, /sdcard, vendor, apex, linkerconfig |
| `repair.sh` | dpkg fix, apt repair, X11 socket cleanup, CPU governor, log truncation |
| `gpu-audit.sh` | GPU stack diagnostic: Adreno, VirGL, Vulkan, EGL, Mesa, DRI paths |
| `status-diagnostics.sh` | Health report: chroot mounts, X11 socket, audio, VirGL, logs |
| `fix-audio.sh` | PulseAudio restart with TCP port 4713 + ALSA sink |
| `clipboard-sync.sh` | Bidirectional clipboard (termux-clipboard ↔ xclip inside chroot) |
| `cleanup.sh` | Stale file cleanup, session log truncation, APT cache purge |

### Debian Chroot (`/usr/local/bin/`)

| Script | Purpose |
|--------|---------|
| `v2-launch.sh` | Chroot init: sources GPU profile, starts system dbus, runs user-session |
| `user-session.sh` | XFCE session: lock-file dedup, dbus-launch, starts xfwm4/xfsettingsd/xfdesktop/xfce4-panel |
| `fix-chroot.sh` | Post-boot fixup: adds groups, creates /run/user/1000, fixes perms |

### Config Files

| Path | Purpose |
|------|---------|
| `/etc/profile.d/99-hardware-acceleration.sh` | GPU env vars: LIBGL_ALWAYS_SOFTWARE=0, MESA_LOADER_DRIVER_OVERRIDE, DISPLAY=:0, PULSE_SERVER=tcp:127.0.0.1:4713 |

## Known Issues & Workarounds

| Issue | Workaround |
|-------|------------|
| `close_range` syscall crashes apps | `LD_PRELOAD=/home/ruusian/fix_mmap.so` |
| Stale X11 socket after crash | `stop-debian.sh` auto-cleans or `rm /data/data/com.termux/files/usr/tmp/.X11-unix/X0` |
| `SESSION_MANAGER=localhost` breaks xfwm4 | `user-session.sh` now does `unset SESSION_MANAGER` |
| `grep -a` needed in scripts | Termux `grep` has no `-a` alias; all `grep` in scripts use explicit `-a` |
| `termux-am` wrapper for `am` | `am` at `/system/bin/am` is root-only; scripts use `termux-am` |
| `pgrep` inside chroot is BusyBox | Must use `-x` for exact name match; no `-f` pattern support |
| Clipboard sync hangs on missing X socket | `clipboard-sync.sh`: added `timeout 2` to xclip calls, X11 socket watch with 10s max wait, auto-exit on socket loss |
| dbus-daemon duplicates | `user-session.sh` uses lock file `/tmp/.xfce-session.lock` for dedup |
| Option 1 idempotency (X11 already running) | If X11 is already up, the startup script's 20s socket wait may time out and roll back; always use option 1 from a clean state or after option 2 |

## TODO

### High Priority
- [ ] Fix option 1 idempotency: when X11 is already running, detect and skip instead of timing out
- [ ] Add `omniroute` exclusion in `stop-debian.sh` (runs inside chroot as ruusian, must not be killed)
- [ ] Remote git URL missing — run `git remote add origin https://github.com/Ruusian5/Systemless-Host-Termux-SU.git`
- [ ] Test `stop-debian.sh` "KILL ALL CHROOT PROCESSES" section to ensure it doesn't kill omniroute
- [ ] Add cleanup of old pip-build-tracker and pip-unpack dirs in /tmp (196 entries, wasted space)

### Medium
- [ ] Merge `origin/repo-modernization` branch into main
- [ ] Remove `backup-all.sh` references from any remaining scripts (already deleted from repo)
- [ ] Run all dashboard options 1-12 in sequence for full pipeline validation
- [ ] Write a regression test suite (bash unit tests for core scripts)
- [ ] Herne's AI Gateway config: verify .env NVIDIA NIM keys are set

### Low
- [ ] Verify `toggle_res.sh` symlink from `res.sh` (broken if res.sh copied from `scripts/`)
- [ ] Remove unused scripts: `build-custom-mesa.sh`, `install-tools.sh`, `kill-hogs.sh`
- [ ] Consolidate duplicate configs: `configs/debian/usr/local/bin/` mirrors some chroot scripts
- [ ] `npm -g ls` may have stale global packages

## Recent Changes

| Date | Change |
|------|--------|
| Jul 6 | Fixed clipboard-sync.sh hangs: added `timeout 2` to xclip calls, 10s max wait for X socket, auto-exit on socket loss |
| Jul 6 | Removed option 10 (Backup Chroot) and `backup-all.sh` from repo |
| Jul 6 | Restored dashboard v2.1 with all original options (reverted v3.0 reduction) |
| Jul 6 | Fixed XFCE black screen: `user-session.sh` v3.3 — unset SESSION_MANAGER, lock-file dedup, conditional dbus-launch |
| Jul 6 | Applied 11 audit fixes: stale X11 cleanup, termux-am path, atomic PID files, grep -a, GPU device permissions, health checks |
| Jul 5 | Full audit of all 13 dashboard scripts — 15 issues found, 11 fixed |
| Jul 5 | Rewrote dashboard to v3.0 (6 essential options only) — later reverted |
| Jul 4 | Added status-diagnostics.sh, improved GPU audit dash compatibility |
| Jun 30 | Initial Debian 12 rootfs deployment |

## Agent Guidelines

If you are an AI agent reading this file:

1. **All commands** in scripts use `su -c` for root operations and `busybox chroot /data/local/tmp/chrootDebian` for chroot operations.
2. **Never kill** `omniroute` or `9router` — they run inside the chroot as user `ruusian`.
3. **X11 socket** at `/data/data/com.termux/files/usr/tmp/.X11-unix/X0` must be `srwxrwxrwx`. It only appears after the Termux:X11 Android app connects.
4. **Chroot /tmp** is bind-mounted from host's `$TERMUX_TMP` (same inode).
5. **`pgrep` inside chroot** is BusyBox; use `-x` for exact name match.
6. **libGL "failed to open zink"** and **"SESSION_MANAGER not defined"** warnings are non-fatal.
7. **`am`** is at `/system/bin/am` (root-only); use `termux-am` wrapper in Termux context.
8. **Test non-interactive options** with `printf '3\n\nq\n' | timeout 30 bash cmds.sh`.
9. **Always use subagents** for background testing (timeout-wrapped) while working on other tasks.
10. **Git remote** needs to be set: `git remote set-url origin https://github.com/Ruusian5/Systemless-Host-Termux-SU.git`.
