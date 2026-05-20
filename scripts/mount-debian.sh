# --- ULTIMATE KERNEL BRIDGE MOUNT (V11.2) ---
# Total Android Hardware & Kernel Autonomy for Debian

DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"
TERMUX_USR="/data/data/com.termux/files/usr"

echo -e "\e[1;33m[+] Establishing Ultimate Kernel Bridge...\e[0m"

# Unlock SUID & Hardware Nodes
su -c "$BUSYBOX mount -o remount,dev,suid /data 2>/dev/null"

mount_bridge() {
    local src="$1"
    local dst="$2"
    local name="$3"
    
    if ! grep -q -w "$dst" /proc/mounts; then
        echo -e "    \e[1;36m[→]\e[0m Mounting $name..."
        su -c "mkdir -p \"$dst\" && $BUSYBOX mount --bind \"$src\" \"$dst\""
    fi
}

# 1. Kernel Hardware Interfaces
mount_bridge "/dev" "$DEBIANPATH/dev" "Devices"
mount_bridge "/sys" "$DEBIANPATH/sys" "Kernel Sys"
mount_bridge "/proc" "$DEBIANPATH/proc" "Processes"
mount_bridge "/config" "$DEBIANPATH/config" "Kernel Config"
mount_bridge "/linkerconfig" "$DEBIANPATH/linkerconfig" "Linker Config"

# 2. Dedicated Device Nodes
if ! grep -q -w "$DEBIANPATH/dev/pts" /proc/mounts; then
    echo -e "    \e[1;36m[→]\e[0m Mounting Terminal PTY..."
    su -c "mkdir -p \"$DEBIANPATH/dev/pts\" && $BUSYBOX mount -t devpts devpts \"$DEBIANPATH/dev/pts\""
fi

# 3. Android System Partitions
mount_bridge "/system" "$DEBIANPATH/system" "Android System"
mount_bridge "/vendor" "$DEBIANPATH/vendor" "Android Vendor"
mount_bridge "/apex" "$DEBIANPATH/apex" "Android Apex"
mount_bridge "/odm" "$DEBIANPATH/odm" "Android ODM"
mount_bridge "/product" "$DEBIANPATH/product" "Android Product"
mount_bridge "/system_ext" "$DEBIANPATH/system_ext" "System Ext"
mount_bridge "/metadata" "$DEBIANPATH/metadata" "Metadata"

# 4. Storage & Bridged Tooling
mount_bridge "/sdcard" "$DEBIANPATH/sdcard" "Internal Storage"
mount_bridge "$TERMUX_USR" "$DEBIANPATH$TERMUX_USR" "Termux Bridge"

# 5. High-Performance Overlays
for dir in "tmp" "run"; do
    if ! grep -q -w "$DEBIANPATH/$dir" /proc/mounts; then
        echo -e "    \e[1;36m[→]\e[0m Initializing $dir overlay..."
        su -c "$BUSYBOX mount -t tmpfs tmpfs \"$DEBIANPATH/$dir\" -o rw,mode=1777,noatime"
    fi
done

if ! grep -q -w "$DEBIANPATH/dev/shm" /proc/mounts; then
    echo -e "    \e[1;36m[→]\e[0m Establishing High-Speed SHM..."
    su -c "mkdir -p \"$DEBIANPATH/dev/shm\" && $BUSYBOX mount -t tmpfs tmpfs \"$DEBIANPATH/dev/shm\" -o rw,size=1G"
fi

# 6. User Runtime Structure
echo -e "    \e[1;36m[→]\e[0m Preparing User Session..."
su -c "
    mkdir -p $DEBIANPATH/run/user/1000
    chown 1000:1000 $DEBIANPATH/run/user/1000
    chmod 700 $DEBIANPATH/run/user/1000
    mkdir -p $DEBIANPATH/run/dbus
    chown 1000:1000 $DEBIANPATH/run/dbus
"

# 7. Socket Bridges & GPU Nodes


# ENSURE GPU ACCESSIBILITY
su -c "chmod 666 $DEBIANPATH/dev/kgsl-3d0 $DEBIANPATH/dev/dri/* 2>/dev/null"

echo -e "\e[1;32m[✓] System Bridge & Hardware Ready.\e[0m"

