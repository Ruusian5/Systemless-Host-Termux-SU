#!/bin/bash
# --- ULTRA-FAST KERNEL BRIDGE (V12.1) ---
DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"
TERMUX_USR="/data/data/com.termux/files/usr"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

# Fast-path check: If /dev is mounted, assume system is ready
if grep -q -w "$DEBIANPATH/dev" /proc/mounts; then
    exit 0
fi

mount_bridge() {
    local src="$1"
    local dst="$2"
    if [ -d "$src" ] || [ -b "$src" ] || [ -c "$src" ]; then
        if ! grep -q -w "$dst" /proc/mounts; then
            if [ ! -e "$dst" ]; then mkdir -p "$dst"; fi
            su -c "$BUSYBOX mount --bind \"$src\" \"$dst\""
        fi
    fi
}

echo -e "\e[1;33m[~] Connecting Hardware Bridges...\e[0m"

mount_bridge "/dev" "$DEBIANPATH/dev"
mount_bridge "/proc" "$DEBIANPATH/proc"
mount_bridge "/sys" "$DEBIANPATH/sys"
mount_bridge "/dev/pts" "$DEBIANPATH/dev/pts"
mount_bridge "/dev/shm" "$DEBIANPATH/dev/shm"
mount_bridge "/system" "$DEBIANPATH/system"
mount_bridge "/vendor" "$DEBIANPATH/vendor"
mount_bridge "/apex" "$DEBIANPATH/apex"
mount_bridge "/linkerconfig" "$DEBIANPATH/linkerconfig"
mount_bridge "/sdcard" "$DEBIANPATH/sdcard"
mount_bridge "$TERMUX_USR" "$DEBIANPATH$TERMUX_USR"
mount_bridge "$TERMUX_TMP" "$DEBIANPATH/tmp"

# High-speed runtime prep
for dir in "run" "var/lock"; do
    TARGET_DIR="$DEBIANPATH/$dir"
    if [ -L "$TARGET_DIR" ] || grep -q -w "$TARGET_DIR" /proc/mounts; then continue; fi
    mkdir -p "$TARGET_DIR"
    su -c "$BUSYBOX mount -t tmpfs tmpfs \"$TARGET_DIR\" -o rw,mode=1777,noatime"
done

su -c "mkdir -p $DEBIANPATH/run/user/1000 && chown 1000:1000 $DEBIANPATH/run/user/1000 && chmod 700 $DEBIANPATH/run/user/1000"
su -c "chmod 666 /dev/kgsl-3d0 /dev/dri/* /dev/video* /dev/ion 2>/dev/null"

echo -e "\e[1;32m[✓] Hardware Link Active.\e[0m"
