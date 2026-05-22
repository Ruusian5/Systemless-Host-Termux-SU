#!/bin/bash
. /etc/profile.d/99-hardware-acceleration.sh
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000
export PULSE_SERVER=tcp:127.0.0.1:4713

# Start High-Speed GPU Compositor (Xrender for stability)
pkill -9 picom 2>/dev/null
picom --backend xrender --vsync -b > /home/ruusian/picom.log 2>&1

# START SESSION
dbus-launch --exit-with-session startxfce4 > /home/ruusian/session_debug.log 2>&1
