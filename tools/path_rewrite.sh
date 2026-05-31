#!/data/data/com.termux/files/usr/bin/bash
# --- PATH REWRITE HELPER ---
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OLD_USER="ruusian"
NEW_USER="Ruusian5"

if [ "$#" -gt 0 ]; then
  REPO_ROOT="$1"
fi

if [ ! -d "$REPO_ROOT" ]; then
  echo "[!] repo root not found: $REPO_ROOT" >&2
  exit 1
fi

find "$REPO_ROOT" -type f ! -path '*/.git/*' -print0 | while IFS= read -r -d '' f; do
  tmp="$(mktemp)"
  sed "s/\b${OLD_USER}\b/${NEW_USER}/g" "$f" > "$tmp" && mv "$tmp" "$f"
done

echo "[path_rewrite] updated paths from '${OLD_USER}' -> '${NEW_USER}'"
