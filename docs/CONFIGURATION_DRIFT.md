# Configuration Drift — Repository vs. Runtime

> **Generated:** 2026-06-01  
> **Goal:** Identify every difference between the repo and the live system

---

## 1. Methodology

| Source | Location | Timestamp |
|--------|----------|-----------|
| Repository (HEAD) | `~/Systemless-Host-Termux-SU` | `e3cf99e` (2026-06-01) |
| Runtime (host scripts) | `~/` (home directory) | Current |
| Runtime (chroot) | `/data/local/tmp/chrootDebian` | Current |

---

## 2. Missing Files (in repo but not deployed to runtime)

These files exist in the repository but are **not present** in the user's `~/cmds.sh` runtime environment (because `cmds.sh` was rewritten during this session):

| File | Repo Path | Runtime | Impact |
|------|-----------|---------|--------|
| `scripts/cmds.sh` | `repo/scripts/cmds.sh` (v16.2) | `~/cmds.sh` (v17, rewritten) | **DRIFT** — runtime has new static menu, repo has old interactive TUI |

The `cmds.sh` in the repo is the **original interactive TUI** with arrow keys, render loop, and live-updating stats. The runtime version was rewritten to a static menu. These will need reconciliation.

---

## 3. Deployed Scripts (repo → runtime)

The `install.sh` copies scripts from `scripts/` to `$HOME`. Current drift:

| Repo Script | Runtime Path | Status |
|-------------|-------------|--------|
| `scripts/startxfce4_chrootDebian.sh` | `~/startxfce4_chrootDebian.sh` | ✅ Present |
| `scripts/stop-debian.sh` | `~/stop-debian.sh` | ✅ Present |
| `scripts/mount-debian.sh` | `~/mount-debian.sh` | ✅ Present |
| `scripts/cli-bridge.sh` | `~/cli-bridge.sh` | ✅ Present |
| `scripts/clipboard-sync.sh` | `~/clipboard-sync.sh` | ✅ Present |
| `scripts/gpu-check.sh` | `~/gpu-check.sh` | ✅ Present |
| `scripts/gpu-audit.sh` | `~/gpu-audit.sh` | ✅ Present |
| `scripts/repair.sh` | `~/repair.sh` | ✅ Present |
| `scripts/toggle_res.sh` | `~/toggle_res.sh` | ✅ Present |
| `scripts/res.sh` | `~/res.sh` | ✅ Present |
| `scripts/install-tools.sh` | `~/install-tools.sh` | ✅ Present |
| `scripts/build-custom-mesa.sh` | `~/build-custom-mesa.sh` | ✅ Present |

**All scripts deployed.** No missing runtime scripts.

---

## 4. Chroot Configuration Files (repo vs. runtime)

### 4.1 Custom Scripts (`/usr/local/bin/`)

| Script | Repo (`configs/debian/usr/local/bin/`) | Runtime (`chroot/usr/local/bin/`) | Match? |
|--------|----------------------------------------|-----------------------------------|--------|
| `chrome.sh` | ✅ Present | ✅ Present | ✅ |
| `cli-init.sh` | ✅ Present | ✅ Present | ✅ |
| `debug-firefox.sh` | ✅ Present | ✅ Present | ✅ |
| `fix-aesthetics` | ✅ Present | ✅ Present | ✅ |
| `fix-display.sh` | ✅ Present | ✅ Present | ✅ |
| `launch-xfce.sh` | ✅ Present | ✅ Present | ✅ |
| `meson` | ✅ Present | ✅ Present | ✅ |
| `reinstall-hermes.sh` | ✅ Present | ✅ Present | ✅ |
| `reset-display.sh` | ✅ Present | ✅ Present | ✅ |
| `reset-panel` | ✅ Present | ✅ Present | ✅ |
| `start-hermes.sh` | ✅ Present | ✅ Present | ✅ |
| `user-session.sh` | ✅ Present | ✅ Present | ✅ |
| `v2-launch.sh` | ✅ Present | ✅ Present | ✅ |
| `v3-cli.sh` | ✅ Present | ✅ Present | ✅ |
| `verify-hardware.sh` | ✅ Present | ✅ Present | ✅ |

**Additional runtime-only scripts** (not in repo):

| Script | Location | Purpose |
|--------|----------|---------|
| `firefox-launcher` | `/usr/local/bin/firefox-launcher` | Firefox wrapper with sandbox disable (created during earlier session debugging) |
| `vlc.sh` | `/usr/local/bin/vlc.sh` | VLC launcher |
| `$cmd` (unknown) | `/usr/local/bin/$cmd` | Shell shim (unknown purpose) |

### 4.2 Hardware Acceleration Profile

| File | Repo | Runtime | Match? |
|------|------|---------|--------|
| `etc/profile.d/99-hardware-acceleration.sh` | ✅ `configs/debian/etc/profile.d/` | ✅ `/etc/profile.d/` | ✅ |

**Additional runtime-only profiles:**

| File | Location | Purpose |
|------|----------|---------|
| `drivers.sh` | `/etc/profile.d/drivers.sh` | Sets `LIBGL_DRIVERS_PATH` and `LD_LIBRARY_PATH` |
| `99-workstation-paths.sh` | `/etc/profile.d/99-workstation-paths.sh` | Adds `/usr/local/*` to PATH |

Both of these are **not in the repo**.

### 4.3 `fix_mmap.c` / `fix_mmap.so`

| File | Repo | Runtime | Match? |
|------|------|---------|--------|
| `fix_mmap.c` | ✅ `configs/debian/home/ruusian/fix_mmap.c` | ✅ `/home/ruusian/fix_mmap.c` | ✅ (runtime has compiled `.so` too) |
| `fix_mmap.so` | ❌ (compiled artifact) | ✅ `/home/ruusian/fix_mmap.so` | Runtime-only (build artifact) |
| `/etc/ld.so.preload` | ❌ (not in repo) | ✅ Contains `/home/ruusian/fix_mmap.so` | Runtime-only configuration |

### 4.4 APT Sources

| Source | Repo | Runtime | Match? |
|--------|------|---------|--------|
| bookworm main | ❌ (not in repo) | ✅ `/etc/apt/sources.list` | Runtime-only |
| bookworm-backports | ❌ | ✅ `/etc/apt/sources.list.d/backports.list` | Runtime-only |
| sid main | ❌ | ✅ `/etc/apt/sources.list.d/sid.list` | Runtime-only |
| NodeSource 20.x | ❌ | ✅ `/etc/apt/sources.list.d/nodesource.sources.bak` | Runtime-only |

**None of the APT source configurations exist in the repo.**

### 4.5 Bash Config

| File | Repo | Runtime | Match? |
|------|------|---------|--------|
| `.bashrc` | ✅ `configs/.bashrc` | ✅ `~/.bashrc` (Termux host) | ❌ **DRIFT** — different content |
| `.hushlogin` | ✅ `configs/.hushlogin` | ✅ `~/.hushlogin` | ✅ (empty) |
| `bash_aliases_host` | ✅ `configs/bash_aliases_host` | ✅ injected into `~/.bashrc` | ✅ |

The repo's `configs/.bashrc` is the **template** installed by `install.sh`. The runtime `~/.bashrc` has been modified (custom prompt, aliases, auto-mount logic, etc.).

---

## 5. Runtime-Only Configuration (Undocumented Fixes)

### 5.1 Known Runtime-Only Patches

| Patch | Location | Description | Discovered |
|-------|----------|-------------|------------|
| `firefox-launcher` script | `/usr/local/bin/firefox-launcher` | Firefox wrapper with all sandboxes disabled | Phase 3 |
| `vlc.sh` | `/usr/local/bin/vlc.sh` | VLC launcher | Phase 3 |
| `drivers.sh` profile | `/etc/profile.d/drivers.sh` | LIBGL_DRIVERS_PATH + LD_LIBRARY_PATH | Phase 3 |
| `99-workstation-paths.sh` | `/etc/profile.d/99-workstation-paths.sh` | PATH extension | Phase 3 |
| `mic.pa` PulseAudio module | `/etc/pulse/default.pa.d/mic.pa` | SLES microphone source | Phase 3 |
| `/etc/ld.so.preload` | chroot root | Preloads `fix_mmap.so` | Phase 3 |
| Compressed chroot archive | `/data/local/tmp/chrootDebian/debian12-arm64.tar.gz` | 133 MB original chroot image | Phase 3 |

### 5.2 D-Bus Workaround

The runtime has a known D-Bus failure (`/tmp` permissions) that is **not addressed** in the repo's scripts. The `v2-launch.sh` and `user-session.sh` attempt to start D-Bus but fail silently.

### 5.3 PulseAudio Configuration

The `startxfce4_chrootDebian.sh` in the runtime was modified (during this session) to:
1. Use `pulseaudio --start` instead of problematic flags
2. Load TCP module explicitly
3. Remove `--load` flag (not supported by Termux PulseAudio)

The repo version still has the original code. **DRIFT.**

---

## 6. Drift Summary

### 6.1 Critical Drifts (must fix)

| # | Issue | Repo | Runtime | Risk |
|---|-------|------|---------|------|
| 1 | `cmds.sh` diverged | Interactive TUI v16.2 | Static menu v17 | HIGH — both versions differ |
| 2 | APT sources undocumented | Not in repo | Multi-source (bookworm + sid + backports) | HIGH — repo can't reproduce runtime |
| 3 | `drivers.sh` + `99-workstation-paths.sh` | Not in repo | Present in chroot | MEDIUM — HW accel depends on these |
| 4 | PulseAudio module config | Not in repo | `mic.pa` present | MEDIUM — audio input |
| 5 | `startxfce4_chrootDebian.sh` modified | Original code | PulseAudio fix applied | MEDIUM — audio startup |
| 6 | `firefox-launcher` script | Not in repo | Current runtime | MEDIUM — Firefox depends on it |

### 6.2 Moderate Drifts

| # | Issue | Repo | Runtime |
|---|-------|------|---------|
| 7 | `.bashrc` (chroot) | Template | Modified with custom PS1, aliases |
| 8 | `.bashrc` (host) | `configs/.bashrc` | Auto-mount logic, HUD, custom prompt |
| 9 | `fix_mmap.so` + `ld.so.preload` | Only `.c` source in repo | Compiled `.so` + preload config present |
| 10 | Chroot tarball | Not in repo | 133 MB at chroot root |

### 6.3 Low Drifts

| # | Issue | Repo | Runtime |
|---|-------|------|---------|
| 11 | Extra scripts (`vlc.sh`, `$cmd`) | Not in repo | Present in `/usr/local/bin/` |
| 12 | `mount-debian.sh.new` | Empty file | Not deployed |
| 13 | `startxfce4_chrootDebian.sh.bak` | Not tracked | Present on disk |

---

## 7. Broken Assumptions (Repo vs. Reality)

### 7.1 Repo Assumes World-Readable `/proc`

The repo's `cmds.sh` and `update_stats` function access `/proc/loadavg` and `/proc/stat` directly. On this device, these files are **not world-readable** (`hidepid=2` mount option). All `su -c` wrappers added during this session are runtime-only fixes not in the repo.

### 7.2 Repo Assumes `grep -oP` Support

The original `cmds.sh` used `grep -oP` for battery parsing. Termux's grep does **not** support `-P` (Perl regex). Fixed to `grep -oE` in runtime but not updated in repo.

### 7.3 Repo Assumes `read -p` Supports ANSI

The original `cmds.sh` used `read -p " ${C_BOLD}Enter: ${NC}"` which prints escape codes literally. Runtime fixed to use `echo -en` before `read`. Repo not updated.

### 7.4 Repo Assumes `pulseaudio --load` Flag

The repo's `startxfce4_chrootDebian.sh` uses `--load module-native-protocol-tcp` which is **not supported** by Termux's PulseAudio. Runtime fixed to use `pactl load-module`.

### 7.5 Repo Assumes Default User is `ruusian`

After the user model audit, the default user `ruusian` (UID 1000) is consistent between repo and runtime. ✅

### 7.6 Repo Assumes `su` Works Without Confirmation

On some Magisk configurations, `su` requires user confirmation on the device screen. The scripts do not handle this case — `su -c` calls that require confirmation will hang indefinitely.
