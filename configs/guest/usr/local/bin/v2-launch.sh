#!/bin/sh
# --- DEBIAN SESSION CONTROLLER (V20) ---
# All XFCE components run as ruusian (desktop user).
# Single-instance via PID file. No pidof/pkill/killall used.
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export DISPLAY=:0
export HOME=/home/ruusian
export XDG_RUNTIME_DIR=/run/user/1000
export XDG_CONFIG_HOME=/home/ruusian/.config
export XDG_CACHE_HOME=/home/ruusian/.cache
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
export TMPDIR=/tmp
unset SESSION_MANAGER

PIDFILE=/tmp/v2-launch.pid
if [ -f "$PIDFILE" ]; then
  oldpid=$(cat "$PIDFILE")
  if kill -0 "$oldpid" 2>/dev/null; then
    echo "Another v2-launch.sh (PID $oldpid) is running -- exiting"
    exit 0
  fi
  rm -f "$PIDFILE"
fi
echo $$ > "$PIDFILE"

mkdir -p /home/ruusian/logs
exec > /home/ruusian/logs/gui-debug.log 2>&1

echo "=== V20 LAUNCH ==="

check_proc() {
  ps -C "$1" 2>/dev/null | grep -q "$1"
}
killa() {
  for pid in $(ps -C "$1" 2>/dev/null | grep "$1" | awk '{print $1}'); do
    kill "$pid" 2>/dev/null || true
  done
}

# 1. Kill ALL old component processes
echo "[1] Cleaning old processes..."
for p in xfce4-session xfwm4 xfce4-panel xfdesktop xfsettingsd xfce4-notifyd xfconfd xscreensaver; do
  killa "$p"
done
for p in dbus-daemon at-spi-bus-launcher gvfsd gvfs-udisks2-volume-monitor gvfs-afc-volume-monitor gvfs-mtp-volume-monitor gvfs-gphoto2-volume-monitor gvfs-goa-volume-monitor gvfsd-trash gvfsd-metadata tumblerd; do
  killa "$p"
done
# Also kill stale sleep processes from old watchdog loops
for pid in $(ps -C sleep 2>/dev/null | grep "sleep 30" | awk '{print $1}'); do
  kill "$pid" 2>/dev/null || true
done
rm -f /run/user/1000/bus /run/dbus/system_bus_socket 2>/dev/null
sleep 2

# 2. Hardware acceleration profile
if [ -f /etc/profile.d/99-hardware-acceleration.sh ]; then
    . /etc/profile.d/99-hardware-acceleration.sh
fi

# 3. Verify X socket
echo "[2] Verifying X socket..."
if [ ! -S /tmp/.X11-unix/X0 ]; then
    echo "ERROR: No X socket at /tmp/.X11-unix/X0"
    echo "Run mount-debian.sh first"
    sleep 5; exit 1
fi
chmod 777 /tmp/.X11-unix 2>/dev/null || true
chmod 777 /tmp/.X11-unix/X0 2>/dev/null || true
echo "[3] X socket OK"

# 4. System bus
echo "[4] Starting D-Bus system bus..."
mkdir -p /run/dbus
dbus-daemon --system --fork --address=unix:path=/run/dbus/system_bus_socket 2>/dev/null

# 5. Runtime dir -- owned by ruusian
mkdir -p /run/user/1000
chown 1000:1000 /run/user/1000
chmod 700 /run/user/1000

# 6. Session bus as ruusian (no root fallback)
echo "[5] Starting D-Bus session bus (as ruusian)..."
rm -f /run/user/1000/bus
/usr/sbin/runuser -u ruusian -g ruusian -p -- dbus-daemon --session --fork --address=unix:path=/run/user/1000/bus 2>/dev/null
sleep 2

# 7. Apply theme
echo "[6] Applying theme..."
sh /home/ruusian/.apply-theme.sh 2>/dev/null

# 8. Start XFCE components -- ALL as ruusian
echo "[7] Starting XFCE components (as ruusian)..."
RU="/usr/sbin/runuser -u ruusian -g ruusian -p --"

$RU xfsettingsd --daemon 2>/dev/null &
sleep 1

$RU xfwm4 --replace --compositor=off 2>/dev/null &
sleep 1

$RU xfce4-panel 2>/dev/null &
$RU xfdesktop 2>/dev/null &
$RU xscreensaver -nosplash 2>/dev/null &

# 9. First-boot setup
if [ ! -f /home/ruusian/.config/.first-boot-done ]; then
    echo "[8] First-boot setup..."
    xdg-mime default xfce4-terminal.desktop application/x-terminal-emulator 2>/dev/null || true
    xdg-mime default firefox-esr.desktop x-scheme-handler/http 2>/dev/null || true
    xdg-mime default thunar.desktop inode/directory 2>/dev/null || true
    touch /home/ruusian/.config/.first-boot-done
fi

# 10. Keep alive -- watchdog, respawns only if crashed
echo "[9] Session running. Watching processes..."
echo "XFCE session started at $(date)" > /home/ruusian/logs/session_debug.log

while true; do
  sleep 30
  for p in xfwm4 xfce4-panel xfdesktop xfsettingsd xscreensaver; do
    if ! check_proc "$p"; then
      echo "[watchdog] Re-spawning $p" >> /home/ruusian/logs/session_debug.log
      case "$p" in
        xfsettingsd) $RU "$p" --daemon 2>/dev/null & ;;
        xfwm4)      $RU "$p" --replace --compositor=off 2>/dev/null & ;;
        *)          $RU "$p" 2>/dev/null &
      esac
      sleep 2
    fi
  done
done
