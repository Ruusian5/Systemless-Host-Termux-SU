#!/bin/bash
# --- HIGH-PERFORMANCE X11 LAUNCHER (V12.5) ---
DEBIANPATH="/data/local/tmp/chrootDebian"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

# 1. CLEANUP
pkill -9 -f termux-x11 2>/dev/null
pkill -9 -f pulseaudio 2>/dev/null
rm -rf "$TERMUX_TMP"/.X0-lock "$TERMUX_TMP"/.X11-unix/X0 2>/dev/null

# 2. START AUDIO
pulseaudio --start --exit-idle-time=-1 2>/dev/null

# 3. START DISPLAY (RE-ENABLING DRI3)
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
# We remove -disable-dri3 to fix the "GLX Version 0" bug
XDG_RUNTIME_DIR=${TERMUX_TMP} termux-x11 :0 -ac > "$HOME/x11_server.log" 2>&1 &

# 4. WAIT FOR SOCKET
echo -e "\e[1;36m[→] Waiting for Display Bridge...\e[0m"
COUNT=0
while [ ! -S "$TERMUX_TMP/.X11-unix/X0" ]; do
    sleep 0.5
    ((COUNT++))
    if [ $COUNT -ge 30 ]; then exit 1; fi
done
chmod 777 "$TERMUX_TMP/.X11-unix/X0"

# 5. HANDOVER
bash mount-debian.sh
su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/env -i \
    HOME=/root \
    TERM=$TERM \
    USER=root \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    TMPDIR=/tmp \
    XDG_RUNTIME_DIR=/tmp \
    /usr/local/bin/v2-launch.sh"
