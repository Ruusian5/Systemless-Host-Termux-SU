#!/bin/bash
# --- ENTERPRISE SHUTDOWN SCRIPT (V0.1) ---
# Refactored for graceful process lifecycle management

DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"

echo -e "\e[1;33m[~] Initiating Graceful System Cleanup...\e[0m"

# 1. Graceful Shutdown (SIGTERM)
su -c "pkill -15 xfce4-session" 2>/dev/null
su -c "pkill -15 xfwm4" 2>/dev/null
su -c "pkill -15 xfdesktop" 2>/dev/null
pkill -15 termux-x11 2>/dev/null
pkill -15 pulseaudio 2>/dev/null
pkill -15 picom 2>/dev/null
pkill -15 socat 2>/dev/null
pkill -f clipboard-sync.sh 2>/dev/null
am force-stop com.termux.x11 2>/dev/null

echo -e "\e[1;36m[→] Waiting for processes to exit cleanly...\e[0m"
sleep 2

# 2. Forceful Cleanup of Orphans (SIGKILL)
su -c "pkill -9 xfce4-session" 2>/dev/null
su -c "pkill -9 xfwm4" 2>/dev/null
su -c "pkill -9 xfdesktop" 2>/dev/null
pkill -9 termux-x11 2>/dev/null
pkill -9 pulseaudio 2>/dev/null
pkill -9 picom 2>/dev/null
pkill -9 socat 2>/dev/null
pkill -f clipboard-sync.sh 2>/dev/null

# 3. Log Rotation
mv ~/x11_server.log ~/x11_server.log.old 2>/dev/null
echo "Log Rotated" > ~/x11_server.log

# 4. Recursive Unmount (Lazy unmounts, only if mounted)
echo -e "\e[1;36m[→] Unmounting chroot filesystems...\e[0m"
if su -c "grep -q 'chrootDebian' /proc/mounts" 2>/dev/null; then
    su -c "$BUSYBOX umount -l $DEBIANPATH/vendor" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/system" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/apex" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/linkerconfig" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/sdcard" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/data/data/com.termux/files/usr" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/tmp" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/run" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/var/lock" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/dev/pts" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/dev/shm" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/dev" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/proc" 2>/dev/null
    su -c "$BUSYBOX umount -l $DEBIANPATH/sys" 2>/dev/null
    echo -e "\e[1;32m[✓] Chroot unmounted.\e[0m"
else
    echo -e "\e[1;33m[~] Chroot not mounted — nothing to unmount.\e[0m"
fi

echo -e "\e[1;32m[✓] All Resources Freed.\e[0m"
