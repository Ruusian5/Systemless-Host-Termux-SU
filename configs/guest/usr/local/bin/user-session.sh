#!/bin/bash
# --- USER SESSION INITIALIZER v6 (manual component launch) ---

exec >> /home/ruusian/logs/gui-debug.log 2>&1

export DISPLAY=:0
export HOME=/home/ruusian
export XDG_RUNTIME_DIR=/run/user/1000
export XDG_CONFIG_HOME=/home/ruusian/.config
export XDG_CACHE_HOME=/home/ruusian/.cache
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [ -f /etc/profile.d/99-hardware-acceleration.sh ]; then
    . /etc/profile.d/99-hardware-acceleration.sh
fi

if [ ! -S /run/user/1000/bus ]; then
    mkdir -p /run/user/1000
    chown 1000:1000 /run/user/1000
    chmod 700 /run/user/1000
    dbus-daemon --session --fork --address=unix:path=/run/user/1000/bus 2>/dev/null
    sleep 1
fi

xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false 2>/dev/null || true
bash /home/ruusian/.apply-theme.sh 2>/dev/null

# Launch all components
xfsettingsd --daemon 2>/dev/null || xfsettingsd 2>/dev/null &
xfce4-panel 2>/dev/null &
xfdesktop 2>/dev/null &

# xfwm4 needs different syntax
xfwm4 2>/dev/null &

# picom
if command -v picom &>/dev/null; then
    picom --config /home/ruusian/.config/picom.conf -b 2>/dev/null || true
fi

# First-boot setup
if [ ! -f /home/ruusian/.config/.first-boot-done ]; then
    bash /usr/local/bin/first-boot-setup.sh 2>/dev/null || true
fi

echo "Starting XFCE4 Session..." > /home/ruusian/logs/session_debug.log
exec xfce4-session
