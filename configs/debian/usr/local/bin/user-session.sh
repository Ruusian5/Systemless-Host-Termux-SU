#!/bin/bash
# --- USER SESSION INITIALIZER (v2.0) ---
# Manual component launch: xfwm4 (no compositor) + xfdesktop + tint2
# Uses /tmp/.gui-null instead of /dev/null (ruusian can't write /dev/null)

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
GUI_NULL=/tmp/.gui-null

if [ -f /etc/profile.d/99-hardware-acceleration.sh ]; then
    . /etc/profile.d/99-hardware-acceleration.sh
fi

rm -f "$XDG_RUNTIME_DIR/ICEauthority" 2>/dev/null
touch "$XDG_RUNTIME_DIR/ICEauthority" 2>/dev/null
chmod 600 "$XDG_RUNTIME_DIR/ICEauthority" 2>/dev/null

export $(dbus-launch)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false 2>/dev/null

echo "Starting XFCE desktop (manual component order)..." > /home/ruusian/session_debug.log

pkill xfce4-panel 2>/dev/null || true

/usr/bin/xfsettingsd --daemon > "$GUI_NULL" 2>&1 &
/usr/bin/xfwm4 --compositor=off --replace > "$GUI_NULL" 2>&1 &
sleep 1
/usr/bin/xfdesktop > "$GUI_NULL" 2>&1 &
/usr/bin/tint2 > "$GUI_NULL" 2>&1 &

while true; do
    sleep 3600
done
