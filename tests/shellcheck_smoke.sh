#!/data/data/com.termux/files/usr/bin/bash
# --- SHELLCHECK SMOKE TEST ---
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "[SKIP] shellcheck not installed"
  exit 0
fi

mapfile -t FILES < <(find "$REPO_ROOT" -type f \( -name '*.sh' -o -name '*.bash' \) ! -path '*/.git/*' ! -path '*/.github/*' | sort)

for f in "${FILES[@]}"; do
  if ! shellcheck -S warning "$f"; then
    FAIL=1
  fi
done

if [ "$FAIL" -ne 0 ]; then
  echo "[FAIL] shellcheck reported issues"
  exit 1
fi

echo "[PASS] shellcheck passed on ${#FILES[@]} files"
