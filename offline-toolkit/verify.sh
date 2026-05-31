#!/bin/bash
# --- PRO WORKSTATION: OFFLINE VERIFICATION TOOL v0.1 ---
# Hardened Enterprise Edition

set -euo pipefail

C_BOLD='\e[1m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
NC='\e[0m'

CHECKSUM_FILE=${1:-"checksums.sha256"}

echo -e "${C_BOLD}>>> Systemless Host Deployment Verification...${NC}"

# 1. Space Check
FREE_SPACE_KB=$(df -k /data | tail -1 | awk '{print $4}')
REQUIRED_KB=6000000 # Minimum ~6GB recommended
if [ "$FREE_SPACE_KB" -lt "$REQUIRED_KB" ]; then
    echo -e "${C_RED}[!] Warning: Low disk space on /data partition. Found: $((FREE_SPACE_KB/1024))MB. Recommended: 6000MB.${NC}"
else
    echo -e "${C_GREEN}[✓] Storage Space OK ($((FREE_SPACE_KB/1024/1024))GB free).${NC}"
fi

# 2. Checksum Verification
if [ ! -f "$CHECKSUM_FILE" ]; then
    echo -e "${C_RED}[!] Error: Checksum file '$CHECKSUM_FILE' not found. Cannot verify archive integrity.${NC}"
    exit 1
fi

echo -e "[~] Verifying archive integrity..."
if sha256sum -c "$CHECKSUM_FILE"; then
    echo -e "${C_GREEN}[✓] Archive integrity verified successfully.${NC}"
else
    echo -e "${C_RED}[✗] Integrity check failed! Do not proceed with installation. Archive may be corrupted.${NC}"
    exit 1
fi
