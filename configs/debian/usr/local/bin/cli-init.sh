#!/bin/bash
# --- DEBIAN CLI USER SESSION (CLEAN) ---
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export XDG_RUNTIME_DIR=/run/user/1000
export PULSE_SERVER=tcp:127.0.0.1:4713
export DISPLAY=:0

# Start user dbus session only if missing
if [ ! -S "/run/user/1000/bus" ] && ! pgrep -u ruusian dbus-daemon > /dev/null; then
    dbus-launch --sh-syntax --exit-with-session > /tmp/dbus-env
    [ -f /tmp/dbus-env ] && . /tmp/dbus-env
fi

[ -f /etc/profile.d/99-hardware-acceleration.sh ] && . /etc/profile.d/99-hardware-acceleration.sh

echo -e "\e[1;32m[✓] Workstation CLI Ready.\e[0m"
# Using -l (login) ensures Bash handles the TTY properly
exec /bin/bash -l
