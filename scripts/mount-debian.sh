#!/data/data/com.termux/files/usr/bin/bash
# --- ENTERPRISE KERNEL BRIDGE (V0.1) ---
# Refactored for strictly idempotent state management
set -euo pipefail

DEBIANPATH="/data/local/tmp/chrootDebian"

if [ ! -d "$DEBIANPATH" ]; then
  echo "[mount-debian] Missing chroot: $DEBIANPATH" >&2
  exit 1
fi

# 1. CORE SUID PROTECTION
# Android mounts /data with nosuid. We MUST fix this or su/sudo will fail.
if /system/bin/mount | grep -q " /data " && /system/bin/mount | grep " /data " | grep -q "nosuid"; then
  echo -e "\e[1;33m[!] nosuid detected on /data. Escalating for SUID permission...\e[0m"
  su -c "mount -o remount,suid /data" || echo -e "\e[1;31m[✗] Failed to enable SUID. Some features may be restricted.\e[0m"
  if /system/bin/mount | grep " /data " | grep -q "nosuid"; then
    echo -e "\e[1;33m[!] SUID still disabled; continuing with limited functionality.\e[0m"
  else
    echo -e "\e[1;32m[✓] SUID Permissions Enabled.\e[0m"
  fi
fi

echo -e "\e[1;33m[~] Synchronizing Hardware Bridges...\e[0m"
su -c bash -s 'DEBIANPATH="$1"' -- "$DEBIANPATH" <<'INNER'
set -euo pipefail
domount() {
  local src="$1"
  local dst="$2"
  if ! grep -q -w "$dst" /proc/mounts; then
    mount --bind "$src" "$dst"
  fi
}
dotmpfs() {
  local dst="$1"
  local opts="$2"
  if ! grep -q -w "$dst" /proc/mounts; then
    mount -t tmpfs tmpfs "$dst" -o "$opts"
  fi
}
mkdir -p "$DEBIANPATH/dev" "$DEBIANPATH/proc" "$DEBIANPATH/sys" "$DEBIANPATH/system" "$DEBIANPATH/vendor" "$DEBIANPATH/apex" "$DEBIANPATH/linkerconfig" "$DEBIANPATH/sdcard" "$DEBIANPATH/data/data/com.termux/files/usr" "$DEBIANPATH/tmp" "$DEBIANPATH/run" "$DEBIANPATH/var/lock" "$DEBIANPATH/dev/shm" "$DEBIANPATH/dev/pts"
domount /dev "$DEBIANPATH/dev"
domount /proc "$DEBIANPATH/proc"
domount /sys "$DEBIANPATH/sys"
domount /dev/pts "$DEBIANPATH/dev/pts"
domount /system "$DEBIANPATH/system"
domount /vendor "$DEBIANPATH/vendor"
domount /apex "$DEBIANPATH/apex"
domount /linkerconfig "$DEBIANPATH/linkerconfig"
domount /sdcard "$DEBIANPATH/sdcard"
domount /data/data/com.termux/files/usr "$DEBIANPATH/data/data/com.termux/files/usr"
domount /data/data/com.termux/files/usr/tmp "$DEBIANPATH/tmp"
# Mount tmpfs components
dotmpfs "$DEBIANPATH/dev/shm" "rw,nosuid,nodev,noatime"
dotmpfs "$DEBIANPATH/run" "rw,mode=1777,noatime"
dotmpfs "$DEBIANPATH/var/lock" "rw,mode=1777,noatime"
# Permissions
mkdir -p "$DEBIANPATH/run/user/1000"
chown 1000:1000 "$DEBIANPATH/run/user/1000"
chmod 700 "$DEBIANPATH/run/user/1000"
chmod 666 /dev/kgsl-3d0 /dev/dri/* /dev/video* /dev/ion /dev/adsp* /dev/adsprpc* 2>/dev/null || true
INNER
echo -e "\e[1;32m[✓] All Bridges Verified and Mounted.\e[0m"
