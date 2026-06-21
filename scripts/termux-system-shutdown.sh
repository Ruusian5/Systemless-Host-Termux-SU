#!/bin/bash
# --- FULL SYSTEM SHUTDOWN (v0.1) ---
# Gracefully stops all services and unmounts bridges

C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_RED='\e[38;5;196m'
C_GREEN='\e[38;5;82m'
NC='\e[0m'

echo -e "${C_BOLD}${C_RED}[System] Initiating Full Shutdown...${NC}"

# 1. Stop Debian bridges
if [ -f ~/stop-debian.sh ]; then
    bash ~/stop-debian.sh
fi

# 2. Kill remaining host processes (exact names only)
pkill -x termux-x11 2>/dev/null
pkill -x pulseaudio 2>/dev/null
pkill -f clipboard-sync.sh 2>/dev/null

# 3. Release wake lock
termux-wake-unlock 2>/dev/null

echo -e "\n${C_BOLD}${C_GREEN}[✓] System Shutdown Complete.${NC}"
echo -e "You may now close Termux safely."
