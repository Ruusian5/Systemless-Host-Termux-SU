#!/bin/bash
# --- USER SESSION INITIALIZER ---

if [ -f /etc/profile.d/99-hardware-acceleration.sh ]; then
    . /etc/profile.d/99-hardware-acceleration.sh
fi

# We must ensure DBUS is running to change xfconf settings
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Disable compositing explicitly! Zink over Termux-X11 cannot handle XFWM4 compositing and will black screen.
xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false 2>/dev/null

echo "Starting XFCE4 Session..." > /home/Ruusian5/session_debug.log
exec startxfce4 >> /home/Ruusian5/session_debug.log 2>&1
