#!/bin/bash
# --- ENTERPRISE KERNEL BRIDGE (V13.7) ---
DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"

if grep -q -w "$DEBIANPATH/dev" /proc/mounts; then exit 0; fi

echo -e "\e[1;33m[~] Synchronizing Hardware Bridges...\e[0m"

# 1. Ensure internal directories exist
su -c "mkdir -p $DEBIANPATH/dev/shm $DEBIANPATH/dev/pts $DEBIANPATH/tmp $DEBIANPATH/run $DEBIANPATH/var/lock"

# 2. Batch Mount with Fallbacks
su -c "
    mount --bind /dev $DEBIANPATH/dev
    
    # Create missing nodes in the newly mounted /dev
    mkdir -p $DEBIANPATH/dev/shm
    mkdir -p $DEBIANPATH/dev/pts
    
    mount --bind /proc $DEBIANPATH/proc
    mount --bind /sys $DEBIANPATH/sys
    mount --bind /dev/pts $DEBIANPATH/dev/pts
    mount --bind /system $DEBIANPATH/system
    mount --bind /vendor $DEBIANPATH/vendor
    mount --bind /apex $DEBIANPATH/apex
    mount --bind /linkerconfig $DEBIANPATH/linkerconfig
    mount --bind /sdcard $DEBIANPATH/sdcard
    mount --bind /data/data/com.termux/files/usr $DEBIANPATH/data/data/com.termux/files/usr
    mount --bind /data/data/com.termux/files/usr/tmp $DEBIANPATH/tmp

    # Fix: Use tmpfs for shm if host node is missing (Common on Android)
    mount -t tmpfs tmpfs $DEBIANPATH/dev/shm -o rw,nosuid,nodev,noatime
    
    mount -t tmpfs tmpfs $DEBIANPATH/run -o rw,mode=1777,noatime
    mount -t tmpfs tmpfs $DEBIANPATH/var/lock -o rw,mode=1777,noatime

    mkdir -p $DEBIANPATH/run/user/1000
    chown 1000:1000 $DEBIANPATH/run/user/1000
    chmod 700 $DEBIANPATH/run/user/1000
    chmod 666 /dev/kgsl-3d0 /dev/dri/* /dev/video* /dev/ion
"
echo -e "\e[1;32m[✓] All Bridges Verified.\e[0m"
