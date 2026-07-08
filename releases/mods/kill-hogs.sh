#!/system/bin/sh
kill -9 $(pgrep -f gvfsd 2>/dev/null) 2>/dev/null
sleep 1
kill -9 $(pgrep -f tumblerd 2>/dev/null) 2>/dev/null
sleep 1
kill -9 $(pgrep -f xfce4-panel 2>/dev/null) 2>/dev/null
sleep 1
kill -9 $(pgrep -f openbox 2>/dev/null) 2>/dev/null
sleep 1
kill -9 $(pgrep -f icewm 2>/dev/null) 2>/dev/null
sleep 1
