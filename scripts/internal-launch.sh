#!/bin/sh
# --- DEBIAN SYSTEM BRIDGE LAUNCHER V6.5 (DRIVER BRIDGE EDITION) ---
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TMPDIR=/tmp

# 1. HARDWARE PERMISSIONS (FORCE)
chmod 666 /dev/dri/* 2>/dev/null
chmod 666 /dev/kgsl-3d0 2>/dev/null

# 2. CORE SERVICES
if ! pgrep -x "haveged" > /dev/null; then /usr/sbin/haveged -w 1024 >/dev/null 2>&1; fi

mkdir -p /tmp/.ICE-unix /tmp/.X11-unix /run/dbus /run/user/1000
chmod 1777 /tmp/.ICE-unix /tmp/.X11-unix /tmp
chown 1000:1000 /run/user/1000
chmod 700 /run/user/1000

if [ ! -S /run/dbus/system_bus_socket ]; then
    rm -f /run/dbus/pid /run/dbus/system_bus_socket
    dbus-daemon --system --fork 2>/dev/null
fi

# 3. USER SESSION LAUNCH (With Universal Driver Bridge)
/usr/bin/su - ruusian -c "
    . /etc/profile.d/99-hardware-acceleration.sh
    export PATH=\$PATH:/data/data/com.termux/files/usr/bin:/system/bin:/vendor/bin
    export DISPLAY=:0 
    export PULSE_SERVER=tcp:127.0.0.1:4713 
    export XDG_RUNTIME_DIR=/run/user/1000

    # UI FIXES
    export XCURSOR_THEME=Adwaita
    export XCURSOR_SIZE=24

    # Disable compositor for stability
    xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false 2>/dev/null
    
    # Start D-Bus User Session
    dbus-launch --exit-with-session startxfce4
"
