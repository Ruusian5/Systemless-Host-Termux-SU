#!/data/data/com.termux/files/usr/bin/bash
# --- PATH SANITY TEST ---
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

bad_paths() {
  # find bare rm -rf style expressions that target absolute host home paths
  # and any references to the lowercase guest username.
  local lower="ruusian"
  local bare_home_re='(^|[\s;"`'\'']|^)\$?HOME/'
  local hardcode_home_re='/data/data/com\.termux/files/home/'

  # lowercase username scan
  if grep -RIn --exclude-dir=.git --exclude-dir=.github -E "\b${lower}\b" "$REPO_ROOT" >/dev/null 2>&1; then
    echo "[FAIL] found lowercase '${lower}' references"
    grep -RIn --exclude-dir=.git --exclude-dir=.github -E "\b${lower}\b" "$REPO_ROOT" || true
    FAIL=1
  else
    echo "[PASS] no lowercase '${lower}' references"
  fi

  # directories assumed to contain placeholders for file writes
  if grep -RIn --exclude-dir=.git --exclude-dir=.github -E "$bare_home_re|$hardcode_home_re" "$REPO_ROOT/scripts" "$REPO_ROOT/offline-toolkit" >/tmp/scripts_path_sanity.txt 2>/dev/null; then
    echo "[WARN] potential bare home paths in scripts:"
    cat /tmp/scripts_path_sanity.txt || true
  else
    echo "[PASS] no bare absolute host home paths detected in scripts"
  fi
}

main() {
  bad_paths
  if [ "$FAIL" -ne 0 ]; then
    exit 1
  fi
}

main "$@"
