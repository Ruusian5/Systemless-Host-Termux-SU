#!/bin/bash
export DISPLAY=:0
[ -f /tmp/dbus-env ] && . /tmp/dbus-env
export SESSION_MANAGER=localhost

# Demote out of Android top-app cgroup to prevent stuck spin loops
echo $$ > /dev/cpuset/cgroup.procs 2>/dev/null
echo $$ > /dev/stune/cgroup.procs 2>/dev/null

# Kill known CPU hogs before starting desktop
for p in gvfsd tumblerd gvfsd-metadata gvfs-io; do
  pkill -9 -x "$p" 2>/dev/null
done

/usr/lib/aarch64-linux-gnu/xfce4/xfconf/xfconfd 2>/dev/null &
sleep 1
xfsettingsd --daemon 2>/dev/null &
sleep 1
xfwm4 --compositor=off --replace 2>/dev/null &
sleep 2
xfdesktop 2>/dev/null &
sleep 2

# Use tint2 instead of xfce4-panel to avoid CPU spin loops
killall tint2 xfce4-panel 2>/dev/null
mkdir -p ~/.config/tint2
[ -f ~/.config/tint2/tint2rc ] || cat > ~/.config/tint2/tint2rc << 'EOF'
panel_items = LTSC
panel_size = 100% 30
panel_margin = 0 0
panel_padding = 4 4
launcher_item_app = /usr/share/applications/xfce4-terminal.desktop
launcher_item_app = /usr/share/applications/thunar.desktop
time1_format = %H:%M
time2_format = %a %d %b
EOF
tint2 2>/dev/null &

# Second pass: kill straggler hogs
sleep 2
pkill -9 -x "gvfsd" 2>/dev/null
pkill -9 -x "tumblerd" 2>/dev/null

echo "Xfce started (tint2 panel)"
ps aux | grep -E "xfwm4|tint2|xfsettingsd|xfdesktop" | grep -v grep | awk '{print $2, $11, $3"%"}'
echo "(xfce4-panel skipped - use tint2 to avoid CPU spin loops)"
