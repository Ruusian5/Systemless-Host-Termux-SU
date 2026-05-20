#!/bin/bash
# --- HIGH PERFORMANCE TERMUX HOST LAUNCHER ---
DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

# 1. TRAP CRASHES & CLEANUP
trap 'termux-wake-unlock 2>/dev/null; echo -e "\e[0m"' EXIT

echo -e "\e[1;36m[System] Initializing Hardware Boot Sequence...\e[0m"

# 2. SMART PROCESS CHECK
if pgrep -f "termux-x11" >/dev/null || [ -S "$TERMUX_TMP/.X11-unix/X0" ]; then
    echo -e "\e[1;33m[!] Stale X11 session detected. Resetting graphics bridge...\e[0m"
    pkill -9 -f termux-x11 2>/dev/null
    rm -rf "$TERMUX_TMP"/.X*-lock "$TERMUX_TMP"/.X11-unix/X* 2>/dev/null
fi

# 3. PREVENT SUSPENSION & PREP
termux-wake-lock
su -c "setenforce 0" 2>/dev/null
chmod 755 "$TERMUX_TMP"
mkdir -p "$TERMUX_TMP/.X11-unix"
chmod 1777 "$TERMUX_TMP/.X11-unix"

# 4. START X11 SERVER
echo -e "\e[1;32m[+] Launching X11 Display Server...\e[0m"
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
# Aggressive lock clearing
rm -f "$TERMUX_TMP"/.X*-lock "$TERMUX_TMP"/.X11-unix/X* 2>/dev/null

# Optimized X11 start command
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac >/dev/null 2>&1 &

# 5. WAIT FOR DISPLAY (High-Speed Loop)
COUNT=0
while [ ! -S "$TERMUX_TMP/.X11-unix/X0" ]; do
    sleep 0.1
    ((COUNT++))
    if [ $COUNT -ge 50 ]; then
        echo -e "\e[1;31m[!] Display Server timeout.\e[0m"
        exit 1
    fi
done
chmod 777 "$TERMUX_TMP/.X11-unix/X0"
echo -e "\e[1;32m[✓] Graphics Bridge Established.\e[0m"

# 6. AUDIO BRIDGE
echo -e "\e[1;32m[+] Syncing Audio Server...\e[0m"
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 2>/dev/null

# 7. MOUNTS
~/mount-debian.sh

# 8. HAND CONTROL TO DEBIAN (Secure Environment Handoff)
echo -e "\e[1;35m[🚀] ENTERING DEBIAN WORKSTATION...\e[0m"

su -c "$BUSYBOX chroot $DEBIANPATH /usr/bin/env -i \
    HOME=/root \
    TERM=$TERM \
    USER=root \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    TMPDIR=/tmp \
    /usr/local/bin/v2-launch.sh"
