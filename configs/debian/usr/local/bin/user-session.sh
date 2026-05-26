#!/bin/bash
# --- USER SESSION INITIALIZER ---

if [ -f /etc/profile.d/99-hardware-acceleration.sh ]; then
    . /etc/profile.d/99-hardware-acceleration.sh
fi

echo "Starting XFCE4 Session..." > /home/ruusian/session_debug.log

# Start a D-Bus session explicitly so xfconf-query can communicate with the daemon
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Now that D-Bus is running, set compositing
xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s true 2>/dev/null

# Launch XFCE using the existing D-Bus session
exec startxfce4 >> /home/ruusian/session_debug.log 2>&1
