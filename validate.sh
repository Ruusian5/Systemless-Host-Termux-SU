#!/data/data/com.termux/files/usr/bin/bash
# --- REPO VALIDATION GATE ---
# Runs shellcheck, dependency preflight, and basic path-sanity checks.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
FAIL=0

check() {
  local label="$1"; shift
  if "$@"; then
    echo "[PASS] $label"
  else
    echo "[FAIL] $label"
    FAIL=1
  fi
}

echo ">>> Repo validation: $REPO_ROOT"

# Ensure we are inside git repo
check "git repository present" git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null

# Mandatory docs
for f in README.md INSTALL.md SECURITY.md ARCHITECTURE.md docs/TEST_PLAN.md docs/UPGRADE_GUIDE.md docs/GPU_ACCELERATION.md; do
  check "doc exists: $f" test -f "$REPO_ROOT/$f"
done

# No remaining lowercase username in source files (script/docs)
LC_RUUSIAN_TXT="$REPO_ROOT/.tmp_repo_validation_lc_ruusian.txt"
mkdir -p "$REPO_ROOT/.tmp" 2>/dev/null || true
if grep -RIn --exclude-dir=.git --exclude-dir=.github -E '\bruusian\b' "$REPO_ROOT" > "$LC_RUUSIAN_TXT" 2>/dev/null; then
  echo "[FAIL] found lowercase 'ruusian' references:"
  cat "$LC_RUUSIAN_TXT"
  FAIL=1
else
  echo "[PASS] no lowercase ruusian references detected"
fi
rm -f "$LC_RUUSIAN_TXT"

# Shellcheck on all bash scripts under scripts/ and offline-toolkit/
if command -v shellcheck >/dev/null 2>&1; then
  mapfile -t SHELL_FILES < <(find "$REPO_ROOT/scripts" "$REPO_ROOT/offline-toolkit" -type f \( -name '*.sh' -o -name '*.bash' \) 2>/dev/null | sort)
  for f in "${SHELL_FILES[@]}"; do
    check "shellcheck: $f" shellcheck -S warning "$f"
  done
else
  echo "[SKIP] shellcheck not installed"
fi

# Key scripts are executable
for f in install.sh validate.sh; do
  check "executable: $f" test -x "$REPO_ROOT/$f"
done

if [ "$FAIL" -eq 1 ]; then
  echo ">>> validation FAILED"
  exit 1
fi

echo ">>> validation PASSED"
