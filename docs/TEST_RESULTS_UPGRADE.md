# Test Results: Upgrade

## Date / Tester
2026-06-01 / Automated validation + manual review

## Procedure
1. Run `bash install.sh` again on an existing setup
2. Verify:
   - No duplicate alias insertion
   - Existing configs preserved
   - No fatal exits

## Results

| Check | Status | Notes |
| --- | --- | --- |
| Idempotent alias add | PASS | |
| Existing files preserved | PASS | |
| No regression in SU path | PASS | |

## Issues
- None blocking
