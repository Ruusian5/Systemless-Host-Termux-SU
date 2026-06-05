# GPU Validation Report

## Device Target
Adreno 640 (example)

## Scope
- VirGL host bridge
- Mesa Zink/VirGL guest config
- Turnip hooks
- `gpu-audit.sh` output

## Validation
- Static audit: PASS
- `gpu-audit.sh` found artifacts: PASS
- Runtime render: MANUAL (not executed here)

## Notes
- Document Adreno family in PHONE_MODEL for broader support.
