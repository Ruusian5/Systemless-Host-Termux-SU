#!/data/data/com.termux/files/usr/bin/bash
# --- MASTER TTY ALLOCATOR ---
set -euo pipefail

DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"
SCRIPT_BIN="/data/data/com.termux/files/usr/bin/script"

if [ ! -d "$DEBIANPATH" ]; then
  echo "[cli-bridge] Missing chroot: $DEBIANPATH" >&2
  exit 1
fi
if [ ! -x "$BUSYBOX" ]; then
  echo "[cli-bridge] Missing busybox: $BUSYBOX" >&2
  exit 1
fi
if [ ! -x "$SCRIPT_BIN" ]; then
  echo "[cli-bridge] Missing script binary: $SCRIPT_BIN" >&2
  exit 1
fi

if ! command -v su >/dev/null 2>&1; then
  echo "[cli-bridge] su not available" >&2
  exit 1
fi

pty_cmd="$BUSYBOX chroot $DEBIANPATH /usr/bin/su -l ruusian -c /usr/local/bin/cli-init.sh"
exec "$SCRIPT_BIN" -q -c "su -c '$pty_cmd'" /dev/null
