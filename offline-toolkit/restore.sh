#!/bin/bash
# --- PRO WORKSTATION: OFFLINE RESTORE TOOL v0.1 ---
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

echo -e "${C_BOLD}${C_CYAN}>>> Initiating Offline Deployment Workstation Restore...${NC}"

# 1. Validation Checks
if [[ $(id -u) -ne 0 ]] && ! command -v su > /dev/null; then
    echo -e "${C_RED}[!] Error: SuperUser (Root) access required for restore.${NC}"
    exit 1
fi

if [ ! -f "$ARCHIVE_PATH" ]; then
    echo -e "${C_RED}[!] Error: Archive '$ARCHIVE_PATH' not found.${NC}"
    echo "Usage: ./restore.sh [path/to/debian-rootfs.tar.zst]"
    exit 1
fi

if ! command -v zstd > /dev/null || ! command -v tar > /dev/null; then
    echo -e "${C_ORANGE}[!] Warning: zstd or tar missing in host. Attempting pkg install...${NC}"
    pkg install -y zstd tar || { echo -e "${C_RED}[!] Failed to install dependencies.${NC}"; exit 1; }
fi

# 2. Check architecture
HOST_ARCH=$(uname -m)
if [[ "$HOST_ARCH" != "aarch64" ]]; then
    echo -e "${C_ORANGE}[!] Warning: Host architecture is $HOST_ARCH. Archive is aarch64. Compatibility not guaranteed.${NC}"
fi

# 3. Preparation
if su -c "test -d $TARGET_DIR"; then
    echo -e "${C_ORANGE}[!] Target directory $TARGET_DIR already exists.${NC}"
    read -p "Are you sure you want to overwrite it? All data will be wiped. (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    echo -e "[~] Wiping existing directory..."
    su -c "rm -rf $TARGET_DIR"
fi

# 4. Extraction
echo -e "${C_BOLD}[+] Extracting $ARCHIVE_PATH to /data/local/tmp ... (This will take a while)${NC}"
su -c "mkdir -p /data/local/tmp"
su -c "tar -I zstd -xpf $ARCHIVE_PATH -C /data/local/tmp"

echo -e "${C_GREEN}[✓] Extraction Complete.${NC}"

# 5. Connect Workstation
echo -e "${C_BOLD}[+] Running bridge installer to hook up Termux...${NC}"
cd "$(dirname "$0")/.."
bash install.sh

echo -e "\n${C_BOLD}${C_GREEN}>>> RESTORE COMPLETE <<<${NC}"
echo -e "Restart Termux and type ${C_CYAN}'agy'${NC} to start your workstation."
