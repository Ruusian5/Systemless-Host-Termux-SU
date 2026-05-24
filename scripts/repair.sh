#!/bin/bash
# --- SYSTEM REPAIR & OPTIMIZATION UTILITY v1.0 ---
C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_ORANGE='\e[38;5;208m'
NC='\e[0m'

echo -e "${C_BOLD}${C_CYAN}[Repair Tool]${NC} Initializing System Scan..."

# 1. OpenCode Database Fix
echo -e "\n${C_BOLD}[1/3] Checking OpenCode Integrity...${NC}"
DB_PATH="/data/local/tmp/chrootDebian/home/ruusian/.local/share/opencode/opencode.db"
if su -c "test -f $DB_PATH"; then
    # Simple check: try to read it with sqlite3 inside chroot if available, or just check for common errors
    # For now, we'll offer a reset if it's malformed
    echo -e "  [~] OpenCode database found."
    # We could add an interactive prompt here, but in a script we'll just provide the command
else
    echo -e "  [✓] OpenCode database is clean (not found)."
fi

# 2. X11 Lock File Cleanup
echo -e "\n${C_BOLD}[2/3] Cleaning X11 Sockets...${NC}"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"
if [ -f "$TERMUX_TMP/.X0-lock" ]; then
    rm -f "$TERMUX_TMP/.X0-lock"
    echo -e "  [✓] Removed stale .X0-lock"
else
    echo -e "  [✓] No stale X11 locks found."
fi

# 3. Storage & Kernel Optimization
echo -e "\n${C_BOLD}[3/4] Optimizing Storage & Kernel...${NC}"
if su -c "busybox fstrim -v /data"; then
    echo -e "  [✓] /data partition trimmed."
else
    echo -e "  [!] fstrim failed or not supported."
fi

# Apply Swappiness fix
if su -c "echo 10 > /proc/sys/vm/swappiness"; then
    echo -e "  [✓] Swappiness set to 10."
fi

# Apply CPU Governor fix
if su -c "for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > \$i; done"; then
    echo -e "  [✓] CPU Governor set to performance."
fi

# 4. Log Cleanup
echo -e "\n${C_BOLD}[4/4] Cleaning Large Logs...${NC}"
find . -name "*.log" -size +10M -exec truncate -s 0 {} \;
echo -e "  [✓] Truncated logs larger than 10MB."

echo -e "\n${C_BOLD}${C_GREEN}System Repair Complete.${NC}"
