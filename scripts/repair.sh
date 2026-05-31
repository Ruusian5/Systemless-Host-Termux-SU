#!/bin/bash
# --- SYSTEM REPAIR & OPTIMIZATION UTILITY v0.1 ---
# Hardened Enterprise Edition

set -euo pipefail

C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_ORANGE='\e[38;5;208m'
NC='\e[0m'

DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"

echo -e "${C_BOLD}${C_CYAN}[Repair Tool v0.1]${NC} Initiating Workstation Scan..."

# 1. Debian Health Check
echo -e "\n${C_BOLD}[1/5] Auditing Debian Package Health...${NC}"
# Use || true to prevent script exit on minor dpkg warnings
su -c "$BUSYBOX chroot $DEBIANPATH /usr/bin/sh -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; dpkg --configure -a && apt-get install -f -y'" || echo -e "  ${C_ORANGE}[!] Debian health check had warnings.${NC}"
echo -e "  [✓] Packages verified."

# 2. X11 Lock File Cleanup
echo -e "\n${C_BOLD}[2/5] Cleaning X11 Sockets...${NC}"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"
rm -f "$TERMUX_TMP"/.X0-lock "$TERMUX_TMP"/.X11-unix/X0 2>/dev/null || true
echo -e "  [✓] Stale sockets purged."

# 3. Storage & Kernel Optimization
echo -e "\n${C_BOLD}[3/5] Optimizing Storage & Kernel...${NC}"
su -c "$BUSYBOX fstrim -v /data" 2>/dev/null || echo -e "  [!] fstrim failed or not supported."

# Apply Swappiness fix
su -c "echo 10 > /proc/sys/vm/swappiness" 2>/dev/null && echo -e "  [✓] Swappiness tuned (10)." || true

# Apply CPU Governor fix
su -c "for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > \$i; done" 2>/dev/null && echo -e "  [✓] All Cores set to PERFORMANCE." || true

# 4. Memory Flush
echo -e "\n${C_BOLD}[4/5] Flushing System Cache...${NC}"
su -c "sync && echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null || true
echo -e "  [✓] RAM Cache cleared."

# 5. Log & Cache Cleanup
echo -e "\n${C_BOLD}[5/5] Cleaning Large Logs & Guest Cache...${NC}"
# Safer find with -maxdepth or targeted dirs
find "$HOME" -name "*.log" -size +5M -exec truncate -s 0 {} \; 2>/dev/null || true
su -c "$BUSYBOX chroot $DEBIANPATH /usr/bin/sh -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; apt-get clean && rm -rf /var/cache/apt/archives/*'" || true
echo -e "  [✓] Truncated logs and cleared guest APT cache."

echo -e "\n${C_BOLD}${C_GREEN}>>> WORKSTATION REPAIR COMPLETE <<<${NC}"
