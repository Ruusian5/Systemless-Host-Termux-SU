# Test Results: Install

## Date / Tester
2026-06-01 / Automated validation + manual review

## Environment
- Termux: latest (pkg-based)
- Chroot: `/data/local/tmp/chrootDebian`
- User: `Ruusian5`

## Procedure
1. Fresh Termux environment
2. Run `bash install.sh`
3. Verify:
   - Aliases added to `.bashrc`
   - Scripts copied
   - Chroot user exists
   - Password set

## Results

| Step | Status | Notes |
| --- | --- | --- |
| Preflight dependency install | PASS | All packages installed without fatal errors |
| Scripts copied to ~ | PASS | |
| .bashrc alias injection | PASS | Idempotent |
| Chroot user creation | PASS | `Ruusian5` present |
| Password set | PASS | Non-default used |

## Issues
- None blocking
