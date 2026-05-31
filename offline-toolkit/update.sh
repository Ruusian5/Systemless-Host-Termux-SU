#!/bin/bash
# --- PRO WORKSTATION: OFFLINE UPDATE TOOL v0.1 ---
# Hardened Enterprise Edition

set -euo pipefail

C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_ORANGE='\e[38;5;208m'
NC='\e[0m'

ARCHIVE_PATH=${1:-"debian-rootfs.tar.zst"}
TARGET_DIR="/data/local/tmp/chrootDebian"

echo -e "${C_BOLD}${C_CYAN}>>> Initiating Offline Workstation Update...${NC}"

if [[ $(id -u) -ne 0 ]] && ! command -v su > /dev/null; then
    echo -e "${C_RED}[!] Error: SuperUser (Root) access required for update.${NC}"
    exit 1
fi

if [ ! -f "$ARCHIVE_PATH" ]; then
    echo -e "${C_RED}[!] Error: Update archive '$ARCHIVE_PATH' not found.${NC}"
    exit 1
fi

echo -e "${C_ORANGE}[!] WARNING: This will overwrite system binaries in the Debian guest.${NC}"
echo -e "Your home directory (/home/ruusian) will be PRESERVED."
read -p "Continue with update? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# We use tar with --keep-newer-files or exclude /home to prevent overwriting user data
echo -e "${C_BOLD}[+] Applying update patch over $TARGET_DIR ...${NC}"
su -c "tar -I zstd -xpf $ARCHIVE_PATH -C /data/local/tmp --exclude='chrootDebian/home/*'"

echo -e "${C_GREEN}[✓] Update Applied Successfully.${NC}"
echo -e "Restart Termux and type ${C_CYAN}'agy'${NC} to start your workstation."
