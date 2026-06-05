#!/data/data/com.termux/files/usr/bin/bash
# --- SUPER-LEVEL SESSION LAUNCHER v4 ---
# Idempotent: if V20 watchdog is already running, just restarts X11/PA
# and returns without re-launching v2-launch.sh.
# 
# Critical fix: checks termux-x11 PROCESS, not just socket file.
# Stale sockets from a crashed server are cleaned up first.
set -uo pipefail

SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
DEBIANPATH="/data/local/tmp/chrootDebian"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"
LOGSDIR="$HOME/logs"
REPO="$HOME/Systemless-Host-Termux-SU"

mkdir -p "$LOGSDIR"
LOGFILE="$LOGSDIR/gui-debug.log"

cleanup() {
  echo -e "\e[1;33m[!] Shutting down...\e[0m"
  for p in termux-x11 pulseaudio; do
    pkill -15 -f "$p" 2>/dev/null || true
    sleep 0.5
  done
  rm -f "$TERMUX_TMP/.X0-lock" "$TERMUX_TMP/.X11-unix/X0" 2>/dev/null
  echo -e "\e[1;32m[✓] Clean exit\e[0m"
}
trap cleanup INT TERM

[ -d "$DEBIANPATH" ] || { echo "Missing chroot: $DEBIANPATH" >&2; exit 1; }

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------

# Check V20 watchdog from INSIDE the chroot
is_watchdog_alive() {
  local pidfile="$DEBIANPATH/tmp/v2-launch.pid"
  [ -f "$pidfile" ] || return 1
  local pid
  pid=$(cat "$pidfile" 2>/dev/null) || return 1
  su -c "chroot '$DEBIANPATH' /bin/kill -0 $pid 2>/dev/null" 2>/dev/null || return 1
  return 0
}

# Check if X11 server process is alive (stale socket guard)
# Note: termux-x11 process name (comm) is "main", not "termux-x11".
# Must use pgrep -f with anchored pattern on full command line.
x11_process_alive() {
  pgrep -f "^termux-x11 " >/dev/null 2>&1
}

# Ensure X11 server is running: clean stale socket, start if needed
ensure_x11() {
  local max_wait=${1:-20}

  if x11_process_alive; then
    echo "      (X11 already running)" >> "$LOGFILE"
    return 0
  fi

  # Stale socket cleanup
  if [ -S "$TERMUX_TMP/.X11-unix/X0" ] || [ -f "$TERMUX_TMP/.X0-lock" ]; then
    echo "      (cleaning stale X socket)" >> "$LOGFILE"
    rm -f "$TERMUX_TMP/.X0-lock" "$TERMUX_TMP/.X11-unix/X0" 2>/dev/null
  fi

  # Ensure X11 socket directory exists
  mkdir -p "$TERMUX_TMP/.X11-unix"

  # Start Android Activity first (X server needs the window surface)
  am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >> "$LOGFILE" 2>&1 || true

  XDG_RUNTIME_DIR="$TERMUX_TMP" termux-x11 :0 -ac -legacy-drawing >> "$LOGSDIR/x11_server.log" 2>&1 &

  for i in $(seq 1 "$max_wait"); do
    x11_process_alive && [ -S "$TERMUX_TMP/.X11-unix/X0" ] && break
    sleep 1
  done

  if ! x11_process_alive || [ ! -S "$TERMUX_TMP/.X11-unix/X0" ]; then
    echo -e "\e[1;31m[!] X11 timeout\e[0m"
    exit 1
  fi
}

# Ensure PulseAudio is running
ensure_pa() {
  if pulseaudio --check 2>/dev/null; then
    echo "      (PA already running)" >> "$LOGFILE"
    return 0
  fi
  pulseaudio --start \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.0/8" \
    --exit-idle-time=-1 >> "$LOGFILE" 2>&1 || true
  sleep 2
}

# ------------------------------------------------------------------

if is_watchdog_alive; then
  if x11_process_alive; then
    running_pid=$(cat "$DEBIANPATH/tmp/v2-launch.pid" 2>/dev/null)
    echo -e "\e[1;32m[✓] V20 watchdog alive (PID $running_pid)\e[0m"
    echo "--- GUI already running: $(date) ---" >> "$LOGFILE"
    # Only ensure PA and X are up, do NOT re-run v2-launch
    ensure_pa
    ensure_x11 10
    bash "$REPO/bin/mount-guest.sh" >> "$LOGFILE" 2>&1
    exit 0
  else
    echo -e "\e[1;33m[!] Watchdog alive but X11 dead. Cleaning up...\e[0m"
    running_pid=$(cat "$DEBIANPATH/tmp/v2-launch.pid" 2>/dev/null)
    su -c "kill -9 $running_pid" 2>/dev/null || true
    rm -f "$DEBIANPATH/tmp/v2-launch.pid"
  fi
fi

echo "--- GUI Launch: $(date) ---" >> "$LOGFILE"

# --- Full startup from scratch ---
ensure_pa
ensure_x11 20
bash "$REPO/bin/mount-guest.sh" >> "$LOGFILE" 2>&1

echo -e "\e[1;35m[Launching GUI...]\e[0m"
su -c "chroot '$DEBIANPATH' /usr/local/bin/v2-launch.sh" >> "$LOGFILE" 2>&1 &
sleep 3
echo -e "\e[1;32m[✓] GUI started (returning to dashboard)\e[0m"
