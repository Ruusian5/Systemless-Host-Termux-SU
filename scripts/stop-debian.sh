#!/bin/bash
# --- ENTERPRISE SHUTDOWN SCRIPT (V13.5) ---
DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"

echo -e "\e[1;33m[~] Initiating System Cleanup...\e[0m"

# 1. Kill Orphans
pkill -9 -f termux-x11 2>/dev/null
pkill -9 -f pulseaudio 2>/dev/null
pkill -9 -f picom 2>/dev/null
pkill -9 -f socat 2>/dev/null
pkill -9 -f clipboard-sync.sh 2>/dev/null

# 2. Log Rotation
mv ~/x11_server.log ~/x11_server.log.old 2>/dev/null
echo "Log Rotated" > ~/x11_server.log

# 3. Recursive Unmount
# We use a static list to avoid command substitution issues
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

echo -e "\e[1;32m[✓] All Resources Freed.\e[0m"
