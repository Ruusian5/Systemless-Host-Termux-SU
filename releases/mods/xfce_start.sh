#!/bin/bash
export DISPLAY=:0
. /tmp/dbus-env 2>/dev/null
export SESSION_MANAGER=localhost

# Demote out of Android top-app cgroup to prevent stuck spin loops
echo $$ > /dev/cpuset/cgroup.procs 2>/dev/null
echo $$ > /dev/stune/cgroup.procs 2>/dev/null

# Kill known CPU hogs (these spin forever in chroot on Android)
for p in gvfsd tumblerd gvfsd-metadata gvfs-io xfce4-panel; do
  pkill -9 -x "$p" 2>/dev/null
done

mkdir -p ~/.config/tint2
cat > ~/.config/tint2/tint2rc << 'TINTCONF'
panel_items = LTSC
panel_size = 100% 30
panel_margin = 0 0
panel_padding = 4 4
launcher_item_app = /usr/share/applications/xfce4-terminal.desktop
launcher_item_app = /usr/share/applications/thunar.desktop
time1_format = %H:%M
time2_format = %a %d %b
TINTCONF
tint2 2>/dev/null &

# Second pass after tint2 starts
sleep 2
pkill -9 -x "gvfsd" 2>/dev/null
pkill -9 -x "tumblerd" 2>/dev/null

ps aux | grep tint2 | grep -v grep
