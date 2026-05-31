# Test Plan
Status: DRAFT

## Scope
- Fresh install
- Upgrade install
- Recovery mode
- GPU stack
- Desktop launch
- Termux:X11 integration

## Test Matrix
| ID | Area | Steps | Expected |
| --- | --- | --- | --- |
| T1 | Install | Run installer on fresh Termux env | Dependencies installed; dashboard shortcut `agy` loads |
| T2 | Upgrade | Re-run installer on existing setup | Configs preserved; no fatal errors |
| T3 | Recovery | Restore corrupted chroot from offline bundle | System boots and mounts correctly |
| T4 | GPU | Run GPU diagnostic after desktop start | Adreno detected; Zink/Turnip active |
| T5 | Desktop | Launch XFCE via dashboard | X11 window opens; clipboard sync runs |
| T6 | Termux:X11 | Start Termux:X11 before desktop | Display binds to X0 without timeout |
| T7 | Network | Run apt update inside chroot | Repositories resolve and update |
| T8 | Audio | Confirm pulseaudio and bridge start | No socket errors; audio from Debian apps routes |

## Pass Criteria
- No shellcheck errors in modified scripts
- No installer regressions on fresh/upgrade paths
- Recovery restores bootable state
