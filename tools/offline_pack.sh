#!/data/data/com.termux/files/usr/bin/bash
# --- OFFLINE PACK HELPER ---
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR="/data/local/tmp/chrootDebian"
OUT_DIR="${1:-$REPO_ROOT/offline-toolkit}"
DATE_TAG="$(date +%Y%m%d-%H%M%S)"
OUT_FILE="$OUT_DIR/debian-rootfs-${DATE_TAG}.tar.zst"

if [ ! -d "$TARGET_DIR" ]; then
  echo "[!] missing chroot: $TARGET_DIR" >&2
  exit 1
fi

if ! command -v zstd >/dev/null 2>&1; then
  echo "[!] zstd not found; install it first" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

su -c "/data/data/com.termux/files/usr/bin/tar -I '/data/data/com.termux/files/usr/bin/zstd -T0 -10' -cpf '$OUT_FILE' -C /data/local/tmp chrootDebian"

echo "[offline_pack] created: $OUT_FILE"
