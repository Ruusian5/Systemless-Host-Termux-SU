#!/bin/sh
# --- DEBIAN XFCE LAUNCHER (FALLBACK MODE) ---
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUUSIAN_UID=$(id -u ruusian 2>/dev/null || echo 1001)

# 1. Setup Runtime Directories
mkdir -p /run/dbus /run/user/$RUUSIAN_UID
chown ruusian:ruusian /run/user/$RUUSIAN_UID
chmod 700 /run/user/$RUUSIAN_UID

# 2. Start DBUS
if [ ! -S /run/dbus/system_bus_socket ]; then
    rm -f /run/dbus/pid /run/dbus/system_bus_socket
    dbus-daemon --system --fork 2>/dev/null
fi

# 3. Environment: FALLBACK MODE (CPU rendering)
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export GALLIUM_DRIVER=llvmpipe
export XDG_RUNTIME_DIR=/run/user/$RUUSIAN_UID

# 4. Launch
/usr/bin/su - ruusian -c "export DISPLAY=$DISPLAY PULSE_SERVER=$PULSE_SERVER GALLIUM_DRIVER=$GALLIUM_DRIVER XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR; dbus-launch --exit-with-session /usr/bin/startxfce4"
