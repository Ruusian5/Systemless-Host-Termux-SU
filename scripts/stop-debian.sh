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
    local sig=$1 name=$2
    if pgrep -x "$name" >/dev/null 2>&1 || pgrep -f "$name" >/dev/null 2>&1; then
        pkill "-$sig" "$name" 2>/dev/null || true
        kill_count=$((kill_count+1))
    fi
}

# ── 2. GRACEFUL SHUTDOWN (SIGTERM) ──────────────────────────────────
echo -e "${C_YELLOW}[→] Sending SIGTERM to running processes...${NC}"
# Inside chroot
su -c "pkill -15 xfce4-session" 2>/dev/null; su -c "pkill -15 xfwm4" 2>/dev/null
su -c "pkill -15 xfdesktop" 2>/dev/null
# Termux-side
kill_proc 15 "termux-x11"
kill_proc 15 "pulseaudio"
kill_proc 15 "picom" 2>/dev/null || true
kill_proc 15 "socat" 2>/dev/null || true
pkill -f clipboard-sync.sh 2>/dev/null || true
pkill -f virgl_test_server_android 2>/dev/null || true

# Kill the Termux:X11 Android activity
am force-stop com.termux.x11 2>/dev/null && echo -e "  ${C_GREEN}[✓] Termux:X11 app closed${NC}" || true

sleep 2

# ── 3. FORCEFUL CLEANUP (SIGKILL) ───────────────────────────────────
echo -e "${C_YELLOW}[→] Forceful cleanup of remaining processes...${NC}"
su -c "pkill -9 xfce4-session" 2>/dev/null; su -c "pkill -9 xfwm4" 2>/dev/null
su -c "pkill -9 xfdesktop" 2>/dev/null
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
if su -c "grep -q 'chrootDebian' /proc/mounts" 2>/dev/null; then
    # tmpfs mounts first (reverse order)
    su -c "$B umount -l $DEBIANPATH/var/lock" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/run" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/dev/shm" 2>/dev/null
    # Bind mounts (reverse order)
    su -c "$B umount -l $DEBIANPATH/tmp" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/data/data/com.termux/files/usr" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/sdcard" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/linkerconfig" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/apex" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/vendor" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/system" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/dev/pts" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/sys" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/proc" 2>/dev/null
    su -c "$B umount -l $DEBIANPATH/dev" 2>/dev/null
    echo -e "  ${C_GREEN}[✓] Chroot unmounted.${NC}"
else
    echo -e "  ${C_YELLOW}[~] Chroot not mounted — nothing to unmount.${NC}"
fi

echo -e "${C_GREEN}[✓] All Resources Freed.${NC}"
