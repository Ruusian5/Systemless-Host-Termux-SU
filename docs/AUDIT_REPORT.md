# Audit Report
## Executive Summary
- Repo health: Moderate
- Critical issues: 2
- High issues: 4
- Medium issues: 6
- Low issues: 3

## Critical
- Inconsistent chroot user naming (`ruusian` vs `Ruusian5`) causes auth failures in launchers.
- Shell shortcuts and dashboard menu can auto-launch GUI unintentionally if invoked from login shell.

## High
- Broad `chmod 777` on X11 and virgl sockets weakens host security.
- Installer lacks dependency preflight and idempotency checks.
- Documentation does not state supported Android security patch levels or Adreno GPU minimums.
- No reproducible test environment or CI workflow exists.

## Medium
- Hardcoded `/data/local/tmp/chrootDebian` path used across scripts without config override.
- GPU diagnostic assumes Adreno 640; limited for other devices.
- Recovery flow assumes user knows rootfs bundle location.
- No package-manifest diff or drift detection for offline installs.
- Display toggle logic tracks only override density/size; smallest width not validated.
- Some scripts reference `~/clipboard-sync.sh` and `~/mount-debian.sh` directly, breaking if users relocate files.

## Low
- README and ARCHITECTURE.md contain minor formatting inconsistencies.
- No CHANGELOG automation or version extraction from repo tags.

## Security Risks
- Uses `su` in multiple scripts without input sanitization.
- X11 socket permissions are world-writable.
- No secret-scanning or pre-commit hooks.

## Recommendations
- Canonicalize username to `Ruusian5` and update all guest paths.
- Replace `777` with group/ACL-based access where possible.
- Add an offline installer and an online installer with validation and logging.
- Add `.github/workflows/shellcheck.yml` and unit-style script tests.
- Add GPU abstraction to support Adreno families beyond 6xx/7xx.
