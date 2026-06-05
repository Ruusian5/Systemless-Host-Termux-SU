# Repository Map

> **Generated:** 2026-06-01  
> **Repository:** `https://github.com/Ruusian5/Systemless-Host-Termux-SU`  
> **Branch (HEAD):** `repo-modernization`  
> **Commit:** `e3cf99e`  
> **Tags:** `v11.2-harden`, `v13.0`  
> **License:** MIT

---

## 1. Folder Tree

```
Systemless-Host-Termux-SU/
├── .git/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   ├── pull_request_template.md
│   └── workflows/
│       └── shellcheck.yml
├── .gitignore
├── .tmp/
├── ARCHITECTURE.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── INSTALL.md
├── LICENSE
├── README.md
├── README.md.bak-20260531-164558
├── ROADMAP.md
├── SECURITY.md
├── TROUBLESHOOTING.md
├── configs/
│   ├── .bashrc
│   ├── .hushlogin
│   ├── bash_aliases_host
│   └── debian/
│       ├── etc/profile.d/
│       │   └── 99-hardware-acceleration.sh
│       ├── home/ruusian/
│       │   └── fix_mmap.c
│       └── usr/local/bin/
│           ├── chrome.sh
│           ├── cli-init.sh
│           ├── debug-firefox.sh
│           ├── fix-aesthetics
│           ├── fix-display.sh
│           ├── launch-xfce.sh
│           ├── meson
│           ├── reinstall-hermes.sh
│           ├── reset-display.sh
│           ├── reset-panel
│           ├── start-hermes.sh
│           ├── user-session.sh
│           ├── v2-launch.sh
│           ├── v3-cli.sh
│           └── verify-hardware.sh
├── docs/
│   ├── AUDIT_REPORT.md
│   ├── AUDIO_STACK.md          (new)
│   ├── CONFIGURATION_DRIFT.md  (new)
│   ├── DEBIAN_DESKTOP_GUIDE.md
│   ├── DEBIAN_STATE.md         (new)
│   ├── GPU_ACCELERATION.md
│   ├── GPU_STACK.md            (new)
│   ├── GUI_ARCHITECTURE.md     (new)
│   ├── PLACEHOLDER.md
│   ├── RECOVERY_GUIDE.md
│   ├── REFACTOR_PLAN.md        (new)
│   ├── REPOSITORY_MAP.md       (this file, new)
│   ├── TERMUX_STATE.md         (new)
│   ├── TERMUX_X11_GUIDE.md
│   ├── TEST_PLAN.md
│   ├── UPGRADE_GUIDE.md
│   └── USER_MODEL.md           (new)
├── install.sh
├── offline-toolkit/
│   ├── BACKUP.md
│   ├── MIGRATION.md
│   ├── RECOVERY.md
│   ├── create_release.sh
│   ├── restore.sh
│   ├── update.sh
│   └── verify.sh
├── scripts/
│   ├── build-custom-mesa.sh
│   ├── cli-bridge.sh
│   ├── clipboard-sync.sh
│   ├── cmds.sh
│   ├── deploy-bridges.sh
│   ├── gpu-audit.sh
│   ├── gpu-check.sh
│   ├── install-tools.sh
│   ├── mount-debian.sh
│   ├── mount-debian.sh.new
│   ├── repair.sh
│   ├── res.sh
│   ├── startxfce4_chrootDebian.sh
│   ├── startxfce4_chrootDebian.sh.bak
│   ├── stop-debian.sh
│   └── toggle_res.sh
├── tests/
│   ├── README.md
│   ├── path_sanity.sh
│   └── shellcheck_smoke.sh
├── tools/
│   ├── README.md
│   ├── offline_pack.sh
│   └── path_rewrite.sh
└── validate.sh
```

---

## 2. File Inventory

### 2.1 Root-Level Scripts

#### `install.sh`
- **Shebang:** `#!/usr/bin/env bash`
- **Purpose:** Automated installer — installs Termux deps, copies scripts to `$HOME`, injects `.bashrc` aliases, hardens Debian chroot (user creation, sudo, packages), builds `fix_mmap.so` kernel bypass
- **Dependencies:** `pkg`, `su`, `busybox`, `chroot`, `gcc` (inside chroot)
- **Entry points:** `bash install.sh` from repo root
- **Callers:** User (manual), `offline-toolkit/restore.sh`
- **Side effects:** Modifies `~/.bashrc`, copies files to `$HOME/`, modifies chroot filesystem
- **Last modified:** 2026-05-31

#### `validate.sh`
- **Shebang:** `#!/data/data/com.termux/files/usr/bin/bash`
- **Purpose:** Validation gate — checks git repo, mandatory docs exist, shellcheck on scripts/
- **Dependencies:** `shellcheck`, `grep`, `find`
- **Entry points:** `bash validate.sh`
- **Callers:** CI, manual testing
- **Side effects:** Creates `.tmp/` directory
- **Last modified:** 2026-06-01

### 2.2 Scripts (`scripts/`)

| File | Shebang | Purpose | Dependencies | Callers | Last Mod |
|------|---------|---------|-------------|---------|----------|
| `cmds.sh` | `#!/bin/bash` | Mission Control Dashboard — 14-option TUI | bash, termux-battery-status, free, df, pgrep, awk | User (alias `agy`) | 2026-06-01 |
| `mount-debian.sh` | `#!/data/data/.../bash` | Kernel Bridge — bind mounts for chroot | su, mount, mktemp | `startxfce4_*.sh`, `cmds.sh`, `.bashrc`, `install.sh` | 2026-06-01 |
| `startxfce4_chrootDebian.sh` | `#!/data/data/.../bash` | GUI session launcher | termux-x11, pulseaudio, virgl_test_server_android | `cmds.sh` (option 0) | 2026-06-01 |
| `stop-debian.sh` | `#!/data/data/.../bash` | Graceful shutdown — kills processes, unmounts | su, pkill, am, busybox | `cmds.sh` (option 12) | 2026-06-01 |
| `cli-bridge.sh` | `#!/data/data/.../bash` | CLI TTY allocator — proper PTY for Debian | busybox, script, su | `cmds.sh` (option 1) | 2026-06-01 |
| `clipboard-sync.sh` | `#!/data/data/.../bash` | Bidirectional clipboard daemon v2.1 | termux-clipboard-get/set, xclip | `startxfce4_*.sh` | 2026-06-01 |
| `gpu-check.sh` | `#!/data/data/.../bash` | GPU diagnostic (read-only) | su, chroot, vulkaninfo, glxinfo | `cmds.sh` (option 2) | 2026-06-01 |
| `gpu-audit.sh` | `#!/data/data/.../bash` | GPU audit + auto-fix | su, chroot, strings, eglinfo | `cmds.sh` (option 10) | 2026-06-01 |
| `repair.sh` | `#!/data/data/.../bash` | System repair + optimization | su, dpkg, apt-get, fstrim | `cmds.sh` (option 3), alias `fix` | 2026-06-01 |
| `toggle_res.sh` | `#!/data/data/.../bash` | Display resolution toggle | wm (system binary) | `cmds.sh` (option 13), `res.sh` | 2026-06-01 |
| `res.sh` | (inline) | Resolution toggle wrapper (calls toggle_res.sh via su) | su | alias `res` | 2026-05-31 |
| `install-tools.sh` | `#!/data/data/.../bash` | Dev tool installer (interactive) | su, chroot, apt | `cmds.sh` (option 4) | 2026-06-01 |
| `build-custom-mesa.sh` | `#!/data/data/.../bash` | Mesa driver builder | su, chroot, apt, git, meson, ninja | `cmds.sh` (option 5) | 2026-06-01 |
| `deploy-bridges.sh` | `#!/bin/bash` | **STUB** — incomplete, only has DEBIANPATH assignment | N/A | N/A | 2026-05-31 |
| `mount-debian.sh.new` | (empty) | Empty WIP file | N/A | N/A | (unknown) |
| `startxfce4_chrootDebian.sh.bak` | `#!/data/data/.../bash` | Backup of session launcher (with `set -euo pipefail`) | (same as original) | (backup) | 2026-06-01 |

### 2.3 Offline Toolkit (`offline-toolkit/`)

| File | Shebang | Purpose | Dependencies | Entry Points |
|------|---------|---------|-------------|--------------|
| `create_release.sh` | `#!/bin/bash` | GitHub release creator | curl, sha256sum | Manual / CI |
| `restore.sh` | `#!/bin/bash` | Full restore from ZST archive | su, zstd, tar | `./restore.sh [archive]` |
| `update.sh` | `#!/bin/bash` | Update preserving `/home/*` | su, zstd, tar | `./update.sh [archive]` |
| `verify.sh` | `#!/bin/bash` | Archive integrity check | sha256sum, df | `./verify.sh [checksums]` |

### 2.4 Test Scripts (`tests/`)

| File | Shebang | Purpose | Dependencies |
|------|---------|---------|-------------|
| `path_sanity.sh` | `#!/data/data/.../bash` | Scans for lowercase `ruusian` + bare absolute paths | grep |
| `shellcheck_smoke.sh` | `#!/data/data/.../bash` | Runs shellcheck on all .sh files | shellcheck, find |

### 2.5 Tools (`tools/`)

| File | Shebang | Purpose | Dependencies |
|------|---------|---------|-------------|
| `offline_pack.sh` | `#!/data/data/.../bash` | Creates ZST archive of chroot | zstd, tar, su |
| `path_rewrite.sh` | `#!/data/data/.../bash` | Bulk path rewriter (replace username strings) | find, sed |

### 2.6 Debian Guest Scripts (`configs/debian/usr/local/bin/`)

| File | Shebang | Purpose | Called By |
|------|---------|---------|-----------|
| `chrome.sh` | `#!/bin/bash` | Chrome/Chromium GPU launcher | User inside Debian |
| `cli-init.sh` | `#!/bin/bash` | CLI session initializer (XDG, D-Bus, PulseAudio) | `cli-bridge.sh` (host) |
| `debug-firefox.sh` | `#!/bin/bash` | Firefox debug launcher with logging | User inside Debian |
| `fix-aesthetics` | `#!/bin/bash` | XFCE visual fix (Arc-Dark theme, panel) | User inside Debian |
| `fix-display.sh` | `#!/bin/bash` | Display sync — add 60Hz/100Hz modes | User inside Debian |
| `launch-xfce.sh` | `#!/bin/sh` | Fallback XFCE launcher (llvmpipe) | User (fallback) |
| `meson` | `#!/usr/bin/python3` | Meson build system wrapper | `build-custom-mesa.sh` |
| `reinstall-hermes.sh` | `#!/bin/bash` | Hermes agent reinstaller | User inside Debian |
| `reset-display.sh` | `#!/bin/bash` | Reset Android resolution to native | User inside Debian |
| `reset-panel` | `#!/bin/bash` | XFCE panel reset + reconfig | User inside Debian |
| `start-hermes.sh` | `#!/bin/bash` | Hermes service runner (loop with restart) | User inside Debian |
| `user-session.sh` | `#!/bin/bash` | XFCE user session init (D-Bus, compositor disable) | `v2-launch.sh` |
| `v2-launch.sh` | `#!/bin/sh` | Session controller v12.6 (D-Bus system, runtime dirs) | `startxfce4_chrootDebian.sh` |
| `v3-cli.sh` | `#!/bin/sh` | CLI entrance with Python PTY | `cli-bridge.sh` (host) |
| `verify-hardware.sh` | `#!/bin/bash` | Hardware verification (vulkaninfo, glxinfo) | User inside Debian |

---

## 3. Configuration Files

| File | Type | Purpose |
|------|------|---------|
| `.gitignore` | Git ignore | 45 patterns excluding OS junk, Termux state, backups, chroot, build outputs |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Issue template | Structured bug report with env fields |
| `.github/ISSUE_TEMPLATE/feature_request.md` | Issue template | Feature request form |
| `.github/pull_request_template.md` | PR template | Summary, checklist, related issues |
| `.github/workflows/shellcheck.yml` | CI workflow | GitHub Actions shellcheck on push/PR |
| `configs/.bashrc` | Bash config | 48-line master .bashrc with aliases, auto-mount, HUD |
| `configs/.hushlogin` | Login config | Empty — suppresses last login message |
| `configs/bash_aliases_host` | Aliases | Quick aliases: agy, res, sd, fix, gpu, deb |
| `configs/debian/etc/profile.d/99-hardware-acceleration.sh` | Profile | GPU acceleration env vars (Zink, Turnip, KGSL) |
| `configs/debian/home/ruusian/fix_mmap.c` | C source | mmap bug bypass for Android kernel 4.14 |

---

## 4. Documentation Files

| File | Status | Purpose |
|------|--------|---------|
| `ARCHITECTURE.md` | ✅ Committed | 3-layer architecture overview |
| `CHANGELOG.md` | ✅ Committed | v0.1 changelog |
| `CONTRIBUTING.md` | ✅ Committed | Development guidelines |
| `INSTALL.md` | ✅ Committed | Installation instructions |
| `LICENSE` | ✅ Committed | MIT License |
| `README.md` | ✅ Committed | Project README (refreshed) |
| `ROADMAP.md` | ✅ Committed | Future development roadmap |
| `SECURITY.md` | ✅ Committed | Security policy |
| `TROUBLESHOOTING.md` | ✅ Committed | Issue troubleshooting guide |
| `offline-toolkit/BACKUP.md` | ✅ Committed | Backup strategy |
| `offline-toolkit/MIGRATION.md` | ✅ Committed | Migration guide |
| `offline-toolkit/RECOVERY.md` | ✅ Committed | Disaster recovery guide |
| `docs/AUDIT_REPORT.md` | ✅ Committed | Security audit findings |
| `docs/DEBIAN_DESKTOP_GUIDE.md` | ✅ Committed | Desktop session guide |
| `docs/GPU_ACCELERATION.md` | ✅ Committed | GPU acceleration guide |
| `docs/PLACEHOLDER.md` | ✅ Committed | Docs index placeholder |
| `docs/RECOVERY_GUIDE.md` | ✅ Committed | Recovery procedures |
| `docs/TERMUX_X11_GUIDE.md` | ✅ Committed | X11 troubleshooting guide |
| `docs/TEST_PLAN.md` | ✅ Committed | Test plan (DRAFT) |
| `docs/UPGRADE_GUIDE.md` | ✅ Committed | Upgrade instructions |
| `tests/README.md` | ✅ Committed | Test directory description |
| `tools/README.md` | ✅ Committed | Tools directory description |

---

## 5. Execution Flow

### Fresh Install
```
git clone → bash install.sh
  ├─ pkg install (dependencies)
  ├─ cp scripts/*.sh ~/
  ├─ Append aliases to ~/.bashrc
  ├─ bash mount-debian.sh
  └─ su -c chroot ... (user, packages, fix_mmap.so)
```

### Normal Session
```
~/.bashrc (Termux launch)
  ├─ Background mount-debian.sh
  ├─ cmds.sh --once (snapshot)
  └─ agy → cmds.sh (interactive)
       ├─ [0] → startxfce4_chrootDebian.sh → chroot v2-launch.sh → XFCE
       ├─ [1] → cli-bridge.sh → chroot cli-init.sh → shell
       └─ [12] → stop-debian.sh (kill, unmount)
```

### Shutdown
```
stop-debian.sh
  ├─ pkill -15 (SIGTERM to all session processes)
  ├─ am force-stop com.termux.x11
  ├─ pkill -9 (remaining)
  └─ busybox umount -l (lazy unmount all bridges)
```

---

## 6. Untracked / Orphaned Files

| File | Status | Reason |
|------|--------|--------|
| `scripts/mount-debian.sh.new` | Untracked | Empty WIP replacement |
| `scripts/startxfce4_chrootDebian.sh.bak` | Untracked | Backup of session launcher |
| `README.md.bak-20260531-164558` | Untracked | Backup of old README |
| `docs/GPU_VALIDATION_REPORT.md` | Untracked | Pending commit |
| `docs/PR_SUMMARY.md` | Untracked | Pending commit |
| `docs/SECURITY_AUDIT.md` | Untracked | Pending commit |
| `docs/SHELLCHECK_REPORT.md` | Untracked | Pending commit |
| `docs/TEST_RESULTS_DESKTOP.md` | Untracked | Pending commit |
| `docs/TEST_RESULTS_INSTALL.md` | Untracked | Pending commit |
| `docs/TEST_RESULTS_UPGRADE.md` | Untracked | Pending commit |
| `docs/RELEASE_READINESS_REPORT.md.*.tmp` | Untracked | Temp file |

---

## 7. Git History (Recent)

```
e3cf99e (HEAD) docs: refresh architecture, readme, security for canonical user
650e04e installer: canonicalize Ruusian5 paths, harden scripts, update offline toolkit docs
247d72e docs: add recovery, X11, desktop, GPU, upgrade guides; add tests/tools; add CI
b366b31 (main) fix: Complete GPU stack restoration with VirGL bridge
f6000ec feat: Introduce comprehensive offline deployment toolkit
42c3516 (origin/main) docs: Comprehensive project documentation
c69f1c1 Hardened Enterprise Release v0.1: Full GPU & Workstation Integration
```

**Branches:** `repo-modernization` (HEAD, ahead of `main` by 3)  
**Tags:** `v11.2-harden`, `v13.0`
