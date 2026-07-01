#!/bin/bash
# Run inside chroot as ruusian user
export DISPLAY=:0
export SESSION_MANAGER=localhost

# DBus session (per-user)
[ -f /tmp/dbus-env ] && . /tmp/dbus-env
if [ -z "$DBUS_SESSION_BUS_PID" ] || ! kill -0 $DBUS_SESSION_BUS_PID 2>/dev/null; then
  eval $(dbus-launch --sh-syntax)
  echo "DBUS_SESSION_BUS_ADDRESS='$DBUS_SESSION_BUS_ADDRESS'" > /tmp/dbus-env
  echo "DBUS_SESSION_BUS_PID=$DBUS_SESSION_BUS_PID" >> /tmp/dbus-env
fi

# Use /tmp/null instead of /dev/null (ruusian can't access /dev/null in chroot)
NULL=/tmp/.gui-null
touch "$NULL"

# Disable dbus services for known CPU hogs (gvfsd, tumblerd, xfce4-panel)
mkdir -p ~/.local/share/dbus-1/services
for f in /usr/share/dbus-1/services/org.gtk.vfs*.service; do
  echo "disabled" > ~/.local/share/dbus-1/services/$(basename $f)
done
for f in /usr/share/dbus-1/services/org.xfce.tumbler*.service; do
  echo "disabled" > ~/.local/share/dbus-1/services/$(basename $f)
done
for f in /usr/share/dbus-1/services/org.xfce.panel*.service; do
  echo "disabled" > ~/.local/share/dbus-1/services/$(basename $f)
done

# Kill known CPU hogs early
for p in gvfsd tumblerd gvfsd-metadata gvfs-io xfce4-panel; do
  pkill -9 -x "$p" 2>/dev/null
done

# xfconfd
/usr/lib/aarch64-linux-gnu/xfce4/xfconf/xfconfd 2>/dev/null &
sleep 1

# xfsettingsd (settings daemon)
nohup xfsettingsd --daemon <"$NULL" >"$NULL" 2>&1 &

# xfwm4 window manager (compositor OFF for performance)
nohup xfwm4 --compositor=off --replace <"$NULL" >"$NULL" 2>&1 &

# xfdesktop (desktop icons)
nohup xfdesktop <"$NULL" >"$NULL" 2>&1 &

sleep 3

# Wallpaper (simple, no xfconf-query — it can spin infinitely)
xsetroot -solid "#2c3e50" 2>/dev/null

# tint2 panel
killall tint2 2>/dev/null
mkdir -p ~/.config/tint2
cat > ~/.config/tint2/tint2rc << 'EOF'
panel_items = LTSC
panel_size = 100% 36
panel_margin = 0 0
panel_padding = 4 4 4
wm_menu = 1
panel_layer = bottom
panel_position = bottom center
task_width = 160
task_centered = 1
task_padding = 4 2 4
launcher_item_app = /usr/share/applications/xfce4-terminal.desktop
launcher_item_app = /usr/share/applications/thunar.desktop
time1_format = %H:%M
time2_format = %a %d %b
time1_font = Sans 11
clock_padding = 2 0
rounded = 0
border_width = 0
background_color = #2c3e50 90
EOF

nohup tint2 <"$NULL" >"$NULL" 2>&1 &

sleep 2

# Final cleanup of sneaky hogs
for p in gvfsd tumblerd gvfsd-metadata gvfs-io; do
  pkill -9 -x "$p" 2>/dev/null
done

# Background watchdog: keep killing gvfsd/tumblerd (dbus reactivates them)
(
  while true; do
    sleep 5
    pkill -9 -x "gvfsd" 2>/dev/null
    pkill -9 -x "tumblerd" 2>/dev/null
    pkill -9 -x "gvfsd-metadata" 2>/dev/null
  done
) &
WATCHDOG_PID=$!

echo "=== GUI READY ==="
ps aux | grep -E "xfwm4|xfdesktop|xfsettingsd|tint2" | grep -v grep

# Keep running so parent shell (chroot-distro) doesn't exit
# and kill our descendant processes
while true; do
  sleep 3600
done
