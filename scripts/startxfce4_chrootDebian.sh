#!/bin/bash
# --- SUPER-LEVEL SESSION LAUNCHER (v0.1) ---
# Hardened Enterprise Edition

set -euo pipefail

DEBIANPATH="/data/local/tmp/chrootDebian"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

# Helper for graceful process termination
terminate_process() {
    local pattern=$1
    if pgrep -f "$pattern" >/dev/null; then
        pkill -15 -f "$pattern" 2>/dev/null || true
        sleep 1
        pkill -9 -f "$pattern" 2>/dev/null || true
    fi
}

echo -e "\e[1;36m[System] Initializing Super-Level Hardware Sequence...\e[0m"

# 1. KERNEL-LEVEL HANDSHAKE
su -c "setenforce 0" 2>/dev/null || echo -e "\e[1;33m[!] SELinux check failed (Non-critical)\e[0m"

terminate_process "termux-x11"
terminate_process "pulseaudio"
terminate_process "virgl_test_server"
terminate_process "clipboard-sync.sh"

# Clean stale locks
rm -rf "$TERMUX_TMP"/.X0-lock "$TERMUX_TMP"/.X11-unix/X0 2>/dev/null

# 2. CORE ENGINES
echo -e "\e[1;32m[+] Starting High-Speed Audio...\e[0m"
pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" 2>/dev/null || true

echo -e "\e[1;32m[+] Starting GPU Bridge (VirGL)...\e[0m"
pkill -f virgl_test_server_android 2>/dev/null || true
virgl_test_server_android --multi-clients > /dev/null 2>&1 &

echo -e "\e[1;32m[+] Launching X11 Display Server...\e[0m"
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 || true
XDG_RUNTIME_DIR=${TERMUX_TMP} termux-x11 :0 -ac -legacy-drawing -disable-dri3 > "$HOME/x11_server.log" 2>&1 &

# Wait for bridges and fix permissions
sleep 2
chmod 777 "$TERMUX_TMP"/.virgl_test 2>/dev/null || true
chmod 777 "$TERMUX_TMP"/.X11-unix/X0 2>/dev/null || true

echo -e "\e[1;32m[+] Launching Universal Clipboard Sync...\e[0m"
bash ~/clipboard-sync.sh > "$HOME/clipboard.log" 2>&1 &


# 3. FAST-PATH BRIDGE
bash ~/mount-debian.sh

# 4. GRAPHICS SYNC (Critical Loop)
echo -e "\e[1;36m[→] Waiting for Graphics Socket...\e[0m"
COUNT=0
while [ ! -S "$TERMUX_TMP/.X11-unix/X0" ]; do
    sleep 0.5
    ((COUNT++))
    if [ $COUNT -ge 40 ]; then
        echo -e "\e[1;31m[!] Display Server timeout. Check x11_server.log\e[0m"
        exit 1
    fi
done
chmod 777 "$TERMUX_TMP/.X11-unix/X0"
echo -e "\e[1;32m[✓] Graphics Bridge Established.\e[0m"

# 5. ENTER WORKSTATION
echo -e "\e[1;35m[🚀] DEBIAN IS RUNNING! Please open the Termux:X11 app to see your desktop.\e[0m"
su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/local/bin/v2-launch.sh"
