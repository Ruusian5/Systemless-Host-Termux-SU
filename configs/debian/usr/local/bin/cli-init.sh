#!/bin/bash
# --- MASTER CLI INITIALIZER (v13.7) ---

RUUSIAN_UID=$(id -u ruusian 2>/dev/null || echo 1001)
export XDG_RUNTIME_DIR=/run/user/$RUUSIAN_UID
export PULSE_SERVER=tcp:127.0.0.1:4713
export DISPLAY=:0

# Start user dbus session if missing
if [ ! -S "$XDG_RUNTIME_DIR/bus" ] && ! pgrep -u ruusian dbus-daemon > /dev/null; then
    dbus-launch --sh-syntax --exit-with-session > /tmp/dbus-env
    [ -f /tmp/dbus-env ] && . /tmp/dbus-env
fi

[ -f /etc/profile.d/99-hardware-acceleration.sh ] && . /etc/profile.d/99-hardware-acceleration.sh

echo -e "\e[1;32m[✓] Workstation CLI Ready.\e[0m"
# We don't exec bash here anymore; we let the su -l handle the shell launch
