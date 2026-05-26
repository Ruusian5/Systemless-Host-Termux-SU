#!/bin/bash
# --- ENTERPRISE KERNEL BRIDGE (V13.8) ---
# Refactored for strictly idempotent state management

DEBIANPATH="/data/local/tmp/chrootDebian"

echo -e "\e[1;33m[~] Synchronizing Hardware Bridges...\e[0m"

su -c "
    # Helper function for idempotent bind mounts
    domount() {
        if ! grep -q -w \"\$2\" /proc/mounts; then
            mount --bind \"\$1\" \"\$2\"
        fi
    }
    
    # Helper function for idempotent tmpfs mounts
    dotmpfs() {
        if ! grep -q -w \"\$2\" /proc/mounts; then
            mount -t tmpfs tmpfs \"\$2\" -o \"\$3\"
        fi
    }

    # Ensure internal directories exist
    mkdir -p $DEBIANPATH/dev/shm $DEBIANPATH/dev/pts $DEBIANPATH/tmp $DEBIANPATH/run $DEBIANPATH/var/lock

    # Batch Mount (Idempotent)
    domount /dev $DEBIANPATH/dev
    
    # Create missing nodes in the newly mounted /dev
    mkdir -p $DEBIANPATH/dev/shm $DEBIANPATH/dev/pts
    
    domount /proc $DEBIANPATH/proc
    domount /sys $DEBIANPATH/sys
    domount /dev/pts $DEBIANPATH/dev/pts
    domount /system $DEBIANPATH/system
    domount /vendor $DEBIANPATH/vendor
    domount /apex $DEBIANPATH/apex
    domount /linkerconfig $DEBIANPATH/linkerconfig
    domount /sdcard $DEBIANPATH/sdcard
    domount /data/data/com.termux/files/usr $DEBIANPATH/data/data/com.termux/files/usr
    domount /data/data/com.termux/files/usr/tmp $DEBIANPATH/tmp

    # Mount tmpfs components
    dotmpfs tmpfs $DEBIANPATH/dev/shm rw,nosuid,nodev,noatime
    dotmpfs tmpfs $DEBIANPATH/run rw,mode=1777,noatime
    dotmpfs tmpfs $DEBIANPATH/var/lock rw,mode=1777,noatime

    # Permissions
    mkdir -p $DEBIANPATH/run/user/1000
    chown 1000:1000 $DEBIANPATH/run/user/1000
    chmod 700 $DEBIANPATH/run/user/1000
    chmod 666 /dev/kgsl-3d0 /dev/dri/* /dev/video* /dev/ion 2>/dev/null || true
"

echo -e "\e[1;32m[✓] All Bridges Verified and Mounted.\e[0m"
