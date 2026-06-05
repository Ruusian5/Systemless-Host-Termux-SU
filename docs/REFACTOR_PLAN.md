# Repository Reorganization Plan

> **Generated:** 2026-06-01  
> **Based on:** Configuration drift analysis between repository and runtime

---

## 1. Current State Assessment

### 1.1 What Works Well

- **Layered architecture** (Host → Bridge → Guest) is clean and well-documented
- **Script isolation** — each script has a single responsibility
- **Offline toolkit** provides disaster recovery
- **Configuration templates** in `configs/` are well-organized
- **Installation** is automated via `install.sh`

### 1.2 What Needs Improvement

| Area | Problem |
|------|---------|
| Naming inconsistency | Mixed conventions (`startxfce4_chrootDebian.sh`, `cli-bridge.sh`, `fix-aesthetics` — no underscore/case standard) |
| Duplicate dashboard code | `cmds.sh` diverged between repo and runtime; two versions exist |
| Chroot configs not in repo | `/etc/profile.d/drivers.sh`, `99-workstation-paths.sh`, `mic.pa`, `firefox-launcher` all runtime-only |
| APT sources undocumented | The multi-source setup (bookworm + sid + backports) is not reproducible from repo |
| Orphaned files | `mount-debian.sh.new`, `startxfce4_chrootDebian.sh.bak`, `README.md.bak` — stale/unused |
| Dead code | `deploy-bridges.sh` is an empty stub |
| Hardcoded paths | Many scripts reference `/data/local/tmp/chrootDebian` directly instead of using a config variable |
| Missing `.gitignore` entries | `*.bak`, `*.new`, temp files should be ignored |
| `sudoers` config not in repo | The `NOPASSWD: ALL` configuration is applied by `install.sh` but not tracked as a config file |

---

## 2. Proposed Folder Structure

```
Systemless-Host-Termux-SU/
├── install.sh
├── validate.sh
├── bin/                         # ← NEW: merged from scripts/ + root scripts
│   ├── cmds.sh                 # Dashboard (single authoritative version)
│   ├── mount-debian.sh
│   ├── start-gui.sh            # ← RENAMED from startxfce4_chrootDebian.sh
│   ├── stop-debian.sh
│   ├── enter-cli.sh            # ← RENAMED from cli-bridge.sh
│   ├── clipboard-sync.sh
│   ├── gpu-check.sh
│   ├── gpu-audit.sh
│   ├── repair.sh
│   ├── toggle-resolution.sh    # ← RENAMED from toggle_res.sh
│   ├── install-tools.sh
│   ├── build-mesa.sh           # ← RENAMED from build-custom-mesa.sh
│   └── deploy-bridges.sh       # ← FIX or REMOVE
├── configs/                     # Keep (rename chroot → guest)
│   ├── termux/                 # ← NEW: Termux host configs
│   │   ├── .bashrc
│   │   ├── .hushlogin
│   │   └── bash_aliases
│   └── guest/                  # ← RENAMED from debian/
│       ├── etc/
│       │   ├── apt/
│       │   │   └── sources.list  # ← NEW: APT sources doc
│       │   ├── pulse/
│       │   │   └── mic.pa        # ← NEW: SLES module config
│       │   ├── sudoers.d/
│       │   │   └── ruusian       # ← NEW: sudoers config
│       │   └── profile.d/
│       │       ├── 99-hardware-acceleration.sh
│       │       ├── drivers.sh       # ← NEW
│       │       └── 99-workstation-paths.sh  # ← NEW
│       ├── home/ruusian/
│       │   └── fix_mmap.c
│       ├── usr/
│       │   ├── local/bin/          # Guest scripts (keep)
│       │   └── share/vulkan/icd.d/ # ← NEW: ICD config
│       └── firefox-launcher         # ← NEW
├── offline-toolkit/             # Keep as-is
├── tests/                       # Keep as-is
├── tools/                       # Keep as-is
├── docs/                        # Keep (already comprehensive)
├── .github/                     # Keep
├── .gitignore                   # Update with new patterns
├── README.md
├── ARCHITECTURE.md
├── INSTALL.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
├── TROUBLESHOOTING.md
└── ROADMAP.md
```

---

## 3. Name Standardization

### 3.1 Naming Convention

- **Hyphenated lowercase** for all scripts (`start-gui.sh`, `toggle-resolution.sh`)
- **Consistent prefixing:** `stop-*`, `start-*`, `*-check.sh`, `*-audit.sh`
- **No underscores** in filenames (replace `_` with `-`)
- **No mixed case** in filenames

### 3.2 Proposed Renames

| Current | Proposed | Reason |
|---------|----------|--------|
| `scripts/cmds.sh` | `bin/cmds.sh` | Keep name (well-known alias `agy`) |
| `scripts/startxfce4_chrootDebian.sh` | `bin/start-gui.sh` | Shorter, clearer |
| `scripts/stop-debian.sh` | `bin/stop-guest.sh` | Consistent with start |
| `scripts/cli-bridge.sh` | `bin/enter-cli.sh` | Action-oriented name |
| `scripts/toggle_res.sh` | `bin/toggle-resolution.sh` | Full words, hyphenated |
| `scripts/build-custom-mesa.sh` | `bin/build-mesa.sh` | Shorter |
| `scripts/res.sh` | `bin/toggle-resolution.sh` | Merge with toggle_res.sh |
| `configs/debian/` | `configs/guest/` | Generic (not Debian-specific) |
| `scripts/mount-debian.sh` | `bin/mount-guest.sh` | Consistent naming |
| `scripts/deploy-bridges.sh` | Remove (stub, broken) | Dead code |

---

## 4. Script Consolidation

### 4.1 Merge Candidates

| Scripts to Merge | Into | Rationale |
|------------------|------|-----------|
| `res.sh` + `toggle_res.sh` | `bin/toggle-resolution.sh` | `res.sh` is a 1-line wrapper |
| `gpu-check.sh` + `gpu-audit.sh` | Keep separate | Different severity (read-only vs. auto-fix) |
| `scripts/cmds.sh` (repo) + `~/cmds.sh` (runtime) | `bin/cmds.sh` | Reconcile into static-menu version |

### 4.2 Remove Candidates

| File | Reason |
|------|--------|
| `scripts/deploy-bridges.sh` | Empty stub, never completed |
| `scripts/mount-debian.sh.new` | Empty, WIP artifact |
| `scripts/startxfce4_chrootDebian.sh.bak` | Backup — belongs in git history, not working tree |
| `README.md.bak-20260531-164558` | Backup — belongs in git history |
| `docs/*.tmp` | Temp files — not committed |

---

## 5. Configuration Files to Add (Runtime → Repo)

The following runtime-specific configurations must be added to the repo:

### 5.1 Chroot Configs

| File | Content | Priority |
|------|---------|----------|
| `configs/guest/etc/apt/sources.list` | bookworm main, sid main, bookworm-backports | HIGH |
| `configs/guest/etc/pulse/default.pa.d/mic.pa` | `load-module module-sles-source` | MEDIUM |
| `configs/guest/etc/sudoers.d/ruusian` | `ruusian ALL=(ALL) NOPASSWD:ALL` | HIGH |
| `configs/guest/etc/profile.d/drivers.sh` | LIBGL_DRIVERS_PATH, LD_LIBRARY_PATH | HIGH |
| `configs/guest/etc/profile.d/99-workstation-paths.sh` | PATH extension | MEDIUM |
| `configs/guest/usr/local/bin/firefox-launcher` | Firefox wrapper with sandbox disable | HIGH |
| `configs/guest/etc/ld.so.preload` | `/home/ruusian/fix_mmap.so` | HIGH |

### 5.2 Host Configs

| File | Content | Priority |
|------|---------|----------|
| `configs/termux/.bashrc` | Current runtime `~/.bashrc` (with auto-mount, aliases, HUD) | MEDIUM |

---

## 6. install.sh Updates

The installer needs to be updated to:

1. Copy scripts from `bin/` instead of `scripts/`
2. Install new config files (drivers.sh, firefox-launcher, sudoers, etc.)
3. Configure APT sources in the new chroot
4. Keep user creation logic (already works)
5. Compile `fix_mmap.so` from source (already works)
6. Set up `ld.so.preload` (new)
7. Track config versions for drift detection

---

## 7. Interface Compatibility

### 7.1 Backward Compatibility

| Current | Replacement | Compat? |
|---------|-------------|---------|
| `bash ~/startxfce4_chrootDebian.sh` | `bash ~/start-gui.sh` | ❌ Symlink needed |
| `alias agy='bash ~/cmds.sh'` | `bash ~/cmds.sh` | ✅ Same |
| `bash ~/mount-debian.sh` | `bash ~/mount-guest.sh` | ❌ Symlink needed |

**Solution:** During the transition, create symlinks:
```bash
ln -s ~/start-gui.sh ~/startxfce4_chrootDebian.sh
ln -s ~/mount-guest.sh ~/mount-debian.sh
```

After one release cycle, remove symlinks and update aliases.

### 7.2 Alias Updates

Update `configs/bash_aliases_host` to point to new script names.

---

## 8. Automation Opportunities

| Task | Current State | Proposed |
|------|-------------|----------|
| Drift detection | Manual | Add `validate.sh --drift` to compare repo vs. runtime |
| Backup | `offline-toolkit/create_release.sh` (broken) | Fix token handling, add to CI |
| CI/CD | Shellcheck only | Add path sanity, drift check, version bump |
| Config sync | Manual copy | Add `sync-configs.sh` to push `configs/` to runtime |
| Versioning | Manual | Add `--version` flag to all scripts, CI version bump |
| Distro-agnostic | Hardcoded `Debian` | Parameterize distro name in config paths |

---

## 9. Priority Order

### Phase A (Immediate — Next Commit)

1. Add runtime-only configs to repo (`drivers.sh`, `firefox-launcher`, `mic.pa`, `ld.so.preload`, `sudoers`, APT sources)
2. Clean up orphaned files (remove `*.bak`, `*.new`, `*.tmp`)
3. Merge `cmds.sh` repo/runtime into single static-menu version
4. Fix `pulseaudio --load` → `pactl load-module` in `startxfce4_chrootDebian.sh`
5. Remove `deploy-bridges.sh` stub

### Phase B (Short-term)

6. Rename scripts (`scripts/` → `bin/`, hyphenated names)
7. Rename `configs/debian/` → `configs/guest/`
8. Add symlinks for backward compatibility
9. Update `install.sh` for new paths
10. Add `--version` flag to all scripts

### Phase C (Medium-term)

11. Add drift detection to `validate.sh`
12. Create `sync-configs.sh` for config deployment
13. Fix `create_release.sh` token handling
14. Add APT source configuration to `install.sh`

### Phase D (Long-term)

15. Parametrize distro (support Ubuntu/Arch chroots)
16. Add automated testing (GUI boot test, GPU detection test)
17. Git hooks for shellcheck + path sanity

---

## 10. Effort Estimation

| Phase | Files Changed | Estimated Effort | Risk |
|-------|--------------|-----------------|------|
| A | ~15 | 2-3 hours | Low — additive changes |
| B | ~25 | 3-4 hours | Medium — path changes may break references |
| C | ~5 | 2-3 hours | Low — new features |
| D | ~10 | 4-6 hours | Medium — larger refactor |

**Total:** ~10-16 hours for full reorganization.
