# Deployment Status Report
**Date:** 2026-06-05  

## 1. Summary
The deployed environment is currently **partially out of sync** with the repository due to the recent `scripts/` -> `bin/` refactoring. Most host-side launchers and aliases are broken. Guest-side critical startup scripts are in sync, but secondary tools (`v3-cli.sh`) have diverged.

---

## 2. Host Reconciliation (Termux)

| File | Repo (bin/) | Deployed ($HOME) | Status | Action |
|------|-------------|------------------|--------|--------|
| `cmds.sh` | 73de3476... | Symlink (Broken) | ❌ BROKEN | Fix symlink |
| `start-gui.sh` | 01b14e7b... | Missing | ❌ MISSING | Deploy |
| `mount-guest.sh` | e6d5c0d0... | Missing | ❌ MISSING | Deploy |
| `stop-guest.sh` | 9264d836... | Missing | ❌ MISSING | Deploy |
| `repair.sh` | 55789005... | Missing | ❌ MISSING | Deploy |

**Observation:** The system was previously configured to copy scripts to `$HOME` or symlink them. The broken symlink `~/cmds.sh -> .../scripts/cmds.sh` confirms the drift.

---

## 3. Guest Reconciliation (Debian)

| File | Repo (guest/) | Deployed (/usr/local/bin) | Status | Action |
|------|---------------|---------------------------|--------|--------|
| `v2-launch.sh` | 64fd4f67... | 64fd4f67... | ✅ MATCH | None |
| `user-session.sh` | be37cbbd... | be37cbbd... | ✅ MATCH | None |
| `v3-cli.sh` | be187efe... | 9ad96efc... | ❌ MISMATCH | Sync to repo |
| `firefox-launcher` | be37cbbd... | be37cbbd... | ✅ MATCH | None |

**Observation:** `v3-cli.sh` has local modifications in the chroot that have not been committed to the repository.

---

## 4. Configuration Drift

### 4.1 Shell Aliases
- Current aliases in `.bashrc` do not match the new `bin/` structure.
- Legacy aliases (`res.sh`, `cli-bridge.sh`) are still present in `.bashrc` but the targets have moved or been renamed.

### 4.2 Permission Mismatches
- Some scripts in `bin/` may lack execution bits in the repo (git-tracked permissions).

---

## 5. Required Actions (Phase 2)
1.  **Sync `v3-cli.sh`:** Copy the live version from chroot to `configs/guest/usr/local/bin/` to capture local patches.
2.  **Redeploy Host Scripts:** Replace broken symlinks and missing files in `$HOME` with the new versions from `bin/`.
3.  **Update `.bashrc`:** Run the updated `install.sh` logic to fix aliases.

---
**Status:** State Reconciliation Complete. Moving to Phase 3 (Startup Pipeline).
