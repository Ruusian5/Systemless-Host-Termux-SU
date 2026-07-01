#!/bin/bash
# --- USER SESSION INITIALIZER ---

if [ -f /etc/profile.d/99-hardware-acceleration.sh ]; then
    . /etc/profile.d/99-hardware-acceleration.sh
fi

# Fix ICE authority (must be writable by ruusian)
rm -f $XDG_RUNTIME_DIR/ICEauthority 2>/dev/null
touch $XDG_RUNTIME_DIR/ICEauthority 2>/dev/null
chmod 600 $XDG_RUNTIME_DIR/ICEauthority 2>/dev/null

# Start DBUS session bus
export $(dbus-launch)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Disable compositing with timeout (prevents infinite spin on slow systems)
timeout 5 xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false 2>/dev/null || true

echo "Starting XFCE4 Session..." > /home/ruusian/session_debug.log
startxfce4 >> /home/ruusian/session_debug.log 2>&1
