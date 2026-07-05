#!/bin/bash
# --- ENTERPRISE KERNEL BRIDGE (V0.1) ---
# Refactored for strictly idempotent state management

DEBIANPATH="/data/local/tmp/chrootDebian"

# 1. CORE SUID PROTECTION
# Android mounts /data with nosuid. We MUST fix this or su/sudo will fail.
if /system/bin/mount | grep " /data " | grep -q "nosuid"; then
    echo -e "\e[1;33m[!] nosuid detected on /data. Escalating for SUID permission...\e[0m"
    su -c "mount -o remount,suid /data"
    if /system/bin/mount | grep " /data " | grep -q "nosuid"; then
         echo -e "\e[1;31m[✗] Failed to enable SUID. Some features may be restricted.\e[0m"
    else
         echo -e "\e[1;32m[✓] SUID Permissions Enabled.\e[0m"
    fi
fi

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
    mkdir -p $DEBIANPATH/dev $DEBIANPATH/proc $DEBIANPATH/sys $DEBIANPATH/system $DEBIANPATH/vendor $DEBIANPATH/apex $DEBIANPATH/linkerconfig $DEBIANPATH/sdcard $DEBIANPATH/data/data/com.termux/files/usr $DEBIANPATH/tmp $DEBIANPATH/run
    # /var/lock is a symlink to /run/lock inside the chroot — replace with a real
    # dir so tmpfs can mount on it (mount doesn't follow symlinks).
    # Skip if already mounted (e.g. from a previous mount-debian run).
    if ! grep -q -w "$DEBIANPATH/var/lock" /proc/mounts 2>/dev/null; then
        rm -rf $DEBIANPATH/var/lock
        mkdir -p $DEBIANPATH/var/lock
    fi
    # Don't create dev/shm here — /dev bind-mount below would hide it
    mkdir -p $DEBIANPATH/dev/pts

    domount /dev $DEBIANPATH/dev
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
    # X11 socket — bind mount if host has it (Termux tmp shared via /tmp bind mount above)
    mkdir -p $DEBIANPATH/tmp/.X11-unix 2>/dev/null || true
    if [ -d /tmp/.X11-unix ]; then
      domount /tmp/.X11-unix $DEBIANPATH/tmp/.X11-unix
    fi

    # Mount tmpfs components (dev/shm AFTER /dev bind mount so target exists)
    mkdir -p $DEBIANPATH/dev/shm 2>/dev/null || true
    dotmpfs tmpfs $DEBIANPATH/dev/shm rw,nosuid,nodev,noatime
    dotmpfs tmpfs $DEBIANPATH/run rw,mode=1777,noatime
    dotmpfs tmpfs $DEBIANPATH/var/lock rw,mode=1777,noatime

    # Permissions
    # NOTE: \$RUUSIAN_UID is escaped so the parent shell doesn't expand it —
    # it's defined INSIDE the su block and must not be pre-expanded.
    RUUSIAN_UID=\$(/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/id -u ruusian 2>/dev/null || echo 1000)
    mkdir -p $DEBIANPATH/run/user/\$RUUSIAN_UID
    chown \$RUUSIAN_UID:\$RUUSIAN_UID $DEBIANPATH/run/user/\$RUUSIAN_UID
    chmod 777 $DEBIANPATH/run/user/\$RUUSIAN_UID
    chmod 666 /dev/kgsl-3d0 /dev/dri/* /dev/video* /dev/ion /dev/adsp* /dev/adsprpc* 2>/dev/null || true
"

echo -e "\e[1;32m[✓] All Bridges Verified and Mounted.\e[0m"
