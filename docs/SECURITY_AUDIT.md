# Security Audit

## Scope
- `install.sh`
- `scripts/*.sh`
- Offline toolkit
- Guest sudo config

## Findings

| Severity | Finding | Remediation |
| --- | --- | --- |
| HIGH | All users can sudo NOPASSWD | Limit to `Ruusian5` required ops |
| MEDIUM | `chmod 777` on sockets | Reduce to group ACL where possible |
| MEDIUM | Hardcoded default password | Rotate immediately; use vault |
| LOW | Info disclosure via banners | Optional |

## Recommendations
- Replace default password in `docs/RECOVERY_GUIDE.md` with rotation instructions
- Add `umask` hardening to guest profiles
