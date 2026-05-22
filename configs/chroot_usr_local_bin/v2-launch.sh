#!/bin/sh
# --- DEBIAN SESSION CONTROLLER (V12.6) ---
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TMPDIR=/tmp

# 1. INITIALIZE HARDWARE
[ -f /etc/profile.d/99-hardware-acceleration.sh ] && . /etc/profile.d/99-hardware-acceleration.sh

# 2. START DBUS
if [ ! -S /run/dbus/system_bus_socket ]; then
    mkdir -p /run/dbus
    rm -f /run/dbus/pid /run/dbus/system_bus_socket
    dbus-daemon --system --fork 2>/dev/null
fi

# 3. PREPARE RUNTIME
mkdir -p /run/user/1000
chown 1000:1000 /run/user/1000
chmod 700 /run/user/1000

# 4. LAUNCH SESSION
exec /usr/bin/su - ruusian -c "/usr/local/bin/user-session.sh"
