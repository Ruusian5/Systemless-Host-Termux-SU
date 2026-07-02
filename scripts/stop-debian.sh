#!/bin/bash
# --- ENTERPRISE SHUTDOWN SCRIPT (V0.2) ---
# Graceful process lifecycle + reverse-order unmount

DEBIANPATH="/data/local/tmp/chrootDebian"
B="/data/data/com.termux/files/usr/bin/busybox"
C_RED='\e[1;31m'; C_GREEN='\e[1;32m'; C_YELLOW='\e[1;33m'; NC='\e[0m'
kill_count=0

echo -e "${C_YELLOW}[~] Initiating Graceful System Cleanup...${NC}"

# ── 1. KILL HELPER ──────────────────────────────────────────────────
kill_proc() {
    local sig=$1 name=$2 flag=${3:--x}
    if pgrep "$flag" "$name" >/dev/null 2>&1; then
        pkill "$flag" "-$sig" "$name" 2>/dev/null || true
        kill_count=$((kill_count+1))
        echo -e "  ${C_YELLOW}[~] Killed: $name${NC}"
    fi
}

# ── 2. GRACEFUL SHUTDOWN (SIGTERM) ──────────────────────────────────
echo -e "${C_YELLOW}[→] Sending SIGTERM to running processes...${NC}"
# Inside chroot (processes share PID namespace with host — accessible via su)
su -c "pkill -15 xfce4-session" 2>/dev/null && echo -e "  ${C_YELLOW}[~] Killed: xfce4-session${NC}" || true
su -c "pkill -15 xfwm4" 2>/dev/null && echo -e "  ${C_YELLOW}[~] Killed: xfwm4${NC}" || true
su -c "pkill -15 xfdesktop" 2>/dev/null && echo -e "  ${C_YELLOW}[~] Killed: xfdesktop${NC}" || true
# Termux-side
kill_proc 15 "termux-x11"
kill_proc 15 "pulseaudio"
kill_proc 15 "picom" 2>/dev/null || true
kill_proc 15 "socat" 2>/dev/null || true
pkill -f clipboard-sync.sh 2>/dev/null && echo -e "  ${C_YELLOW}[~] Killed: clipboard-sync${NC}" || true
pkill -f virgl_test_server_android 2>/dev/null && echo -e "  ${C_YELLOW}[~] Killed: virgl_test_server_android${NC}" || true

# Kill the Termux:X11 Android activity (immune in top-app cgroup, best-effort)
command -v am >/dev/null 2>&1 && am force-stop com.termux.x11 2>/dev/null && echo -e "  ${C_GREEN}[✓] Termux:X11 activity stopped${NC}" || true

sleep 2

# ── 3. FORCEFUL CLEANUP (SIGKILL) ───────────────────────────────────
echo -e "${C_YELLOW}[→] Forceful cleanup of remaining processes...${NC}"
su -c "pkill -9 xfce4-session" 2>/dev/null || true
su -c "pkill -9 xfwm4" 2>/dev/null || true
su -c "pkill -9 xfdesktop" 2>/dev/null || true
pkill -9 termux-x11 2>/dev/null || true
pkill -9 pulseaudio 2>/dev/null || true
pkill -9 picom 2>/dev/null || true
pkill -9 socat 2>/dev/null || true
pkill -f clipboard-sync.sh 2>/dev/null || true
pkill -f virgl_test_server_android 2>/dev/null || true

# Clean up clipboard-sync PID file
rm -f /data/data/com.termux/files/usr/tmp/clipboard-sync.pid 2>/dev/null

if [ $kill_count -gt 0 ]; then
    echo -e "  ${C_GREEN}[✓] $kill_count process(es) stopped${NC}"
else
    echo -e "  ${C_YELLOW}[~] No processes needed stopping${NC}"
fi

# ── 4. LOG ROTATION ─────────────────────────────────────────────────
if [ -f ~/x11_server.log ]; then
    mv ~/x11_server.log ~/x11_server.log.old 2>/dev/null
    echo "Log Rotated" > ~/x11_server.log
fi

# ── 5. UNMOUNT (reverse of mount order) ──────────────────────────────
echo -e "${C_YELLOW}[→] Unmounting chroot filesystems...${NC}"
umount_count=0
if su -c "grep -q 'chrootDebian' /proc/mounts" 2>/dev/null; then
    for mp in var/lock run dev/shm tmp data/data/com.termux/files/usr sdcard linkerconfig apex vendor system dev/pts sys proc dev; do
        su -c "$B umount -l $DEBIANPATH/$mp" 2>/dev/null && umount_count=$((umount_count+1))
    done
    echo -e "  ${C_GREEN}[✓] $umount_count mount(s) unmounted.${NC}"
else
    echo -e "  ${C_YELLOW}[~] Chroot not mounted — nothing to unmount.${NC}"
fi

echo -e "${C_GREEN}[✓] All Resources Freed.${NC}"
