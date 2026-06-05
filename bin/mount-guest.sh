#!/bin/bash
# mount-guest.sh - v4 (Hardened)
DEBIANPATH="/data/local/tmp/chrootDebian"

echo "[] Preparing chroot environment..."

# Helper to check if already mounted
is_mounted() {
  grep -q " $1 " /proc/mounts
}

# 1. Mount basic system filesystems
# We MUST use bind mounts for /dev to inherit correct SELinux contexts on Android.
for f in dev proc sys dev/pts; do
  target="$DEBIANPATH/$f"
  if ! is_mounted "$target"; then
    echo "  [+] Mounting $f..."
    su -c "mount --bind /$f $target"
  fi
done

# 2. Mount X11 socket (Termux -> Debian)
X11_SOURCE="/data/data/com.termux/files/usr/tmp/.X11-unix"
X11_TARGET="$DEBIANPATH/tmp/.X11-unix"
mkdir -p "$X11_TARGET"
if ! is_mounted "$X11_TARGET"; then
  echo "  [+] Mounting X11 socket..."
  su -c "mount --bind $X11_SOURCE $X11_TARGET"
fi

# 3. Fix /tmp permissions
su -c "chmod 1777 $DEBIANPATH/tmp"

# 4. Mount GPU devices (Optional but recommended for direct access)
for gpu in /dev/dri /dev/kgsl-3d0; do
  if [ -e "$gpu" ] && ! is_mounted "$DEBIANPATH$gpu"; then
    echo "  [+] Mounting GPU node: $gpu"
    su -c "mount --bind $gpu $DEBIANPATH$gpu"
  fi
done

# 5. Mount sdcard
if ! is_mounted "$DEBIANPATH/sdcard"; then
  echo "  [+] Mounting /sdcard..."
  su -c "mount --bind /sdcard $DEBIANPATH/sdcard"
fi

echo "[] Chroot ready at $DEBIANPATH"
