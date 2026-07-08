#!/bin/bash
# --- RESTORE: apply GPU drivers + modifications into a fresh Debian chroot ---
# Usage: bash restore.sh <chroot-path>
set -euo pipefail

CHROOT="${1:-/data/local/tmp/chrootDebian}"
BUNDLE="$(cd "$(dirname "$0")/.." && pwd)"
[ -d "$CHROOT" ] || { echo "Chroot not found: $CHROOT"; exit 1; }

echo "[*] Installing GPU drivers + modifications into $CHROOT"

# 1. GPU drivers (preserve paths: they live under /usr and /etc)
cp -p "$BUNDLE/gpu-drivers/usr/lib/aarch64-linux-gnu/libvulkan_freedreno.so" \
      "$CHROOT/usr/lib/aarch64-linux-gnu/" 2>/dev/null || \
  install -Dm755 "$BUNDLE/gpu-drivers/usr/lib/aarch64-linux-gnu/libvulkan_freedreno.so" \
      "$CHROOT/usr/lib/aarch64-linux-gnu/libvulkan_freedreno.so"
cp -p "$BUNDLE/gpu-drivers/usr/lib/aarch64-linux-gnu/dri/zink_dri.so" \
      "$CHROOT/usr/lib/aarch64-linux-gnu/dri/zink_dri.so"
install -Dm644 "$BUNDLE/gpu-drivers/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json" \
      "$CHROOT/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json"
install -Dm644 "$BUNDLE/gpu-drivers/etc/profile.d/99-hardware-acceleration.sh" \
      "$CHROOT/etc/profile.d/99-hardware-acceleration.sh"

# 2. Chroot-side modifications
install -Dm755 "$BUNDLE/mods/usr/local/bin/user-session.sh" "$CHROOT/usr/local/bin/user-session.sh"
install -Dm755 "$BUNDLE/mods/usr/local/bin/v2-launch.sh"    "$CHROOT/usr/local/bin/v2-launch.sh"
install -Dm755 "$BUNDLE/mods/home/ruusian/fix_mmap.so"      "$CHROOT/home/ruusian/fix_mmap.so"
install -Dm644 "$BUNDLE/mods/home/ruusian/fix_mmap.c"       "$CHROOT/home/ruusian/fix_mmap.c"
install -Dm755 "$BUNDLE/mods/home/ruusian/vk_test"          "$CHROOT/home/ruusian/vk_test" 2>/dev/null || true

# 3. Recreate ruusian user (UID 1000) with sudo + password 1234
if ! chroot "$CHROOT" id ruusian >/dev/null 2>&1; then
  chroot "$CHROOT" useradd -m -u 1000 -s /bin/bash ruusian
  echo "ruusian:1234" | chroot "$CHROOT" chpasswd
  chroot "$CHROOT" usermod -aG sudo,audio,video,input,render,disk,plugdev ruusian
fi

# 4. Replay package manifest for a reproducible install
if [ -f "$BUNDLE/packages.manifest" ]; then
  cp "$BUNDLE/packages.manifest" "$CHROOT/tmp/packages.manifest"
  chroot "$CHROOT" bash -c "dpkg --set-selections < /tmp/packages.manifest && apt-get -y dselect-upgrade"
  rm -f "$CHROOT/tmp/packages.manifest"
fi

echo "[*] Done. Start the desktop from the host dashboard: bash ~/cmds.sh -> [1]"
