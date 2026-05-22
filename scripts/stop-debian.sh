#!/bin/bash

# --- ULTIMATE STOP SCRIPT (V4) ---
DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

echo -e "\e[1;33m[~] Initiating Nuclear Shutdown...\e[0m"

# 1. Kill Termux Helpers (Using -f to match full command line)
pkill -9 -f termux-x11 2>/dev/null
pkill -9 -f Xwayland 2>/dev/null
pkill -9 -f pulseaudio 2>/dev/null
pkill -9 -f virgl_test_server 2>/dev/null
killall -9 termux-wake-lock 2>/dev/null

# 2. Kill all processes holding X11 sockets
su -c "lsof | grep '.X11-unix/X0' | awk '{print \$2}' | xargs kill -9" 2>/dev/null

# 3. Targeted Kill of Debian Processes
su -c "
pkill -9 -x xfce4-session
pkill -9 -x xfwm4
pkill -9 -x dbus-daemon
pkill -9 -x dbus-launch
pkill -9 -x startxfce4
" 2>/dev/null

# 4. Deep Scan fallback: Kill ALL processes inside the chroot directory
su -c "
for pid_dir in /proc/[0-9]*; do
    [ -d \"\$pid_dir\" ] || continue
    pid=\$(basename \"\$pid_dir\")
    root_link=\$(readlink \"\$pid_dir/root\" 2>/dev/null)
    if [[ \"\$root_link\" == \"$DEBIANPATH\"* ]]; then
        kill -9 \$pid 2>/dev/null
    fi
done
" 2>/dev/null

# 5. Aggressive Socket Cleanup
echo -e "\e[1;33m[~] Cleaning Graphics & Audio Locks...\e[0m"
rm -f "$TERMUX_TMP"/.X*-lock "$TERMUX_TMP"/.X11-unix/X* 2>/dev/null
rm -rf "$TERMUX_TMP"/.virgl* "$TERMUX_TMP"/virgl_socket 2>/dev/null
rm -f "$TERMUX_TMP"/pulse-* 2>/dev/null

mkdir -p "$TERMUX_TMP"/.X11-unix
chmod 1777 "$TERMUX_TMP" "$TERMUX_TMP"/.X11-unix

# 6. Comprehensive Unmount
echo -e "\e[1;33m[~] Releasing Kernel Bridges...\e[0m"
su -c "
# Get all active mounts under DEBIANPATH and unmount them in reverse order
mounts=\$(grep \"$DEBIANPATH\" /proc/mounts | awk '{print \$2}' | sort -r)
for m in \$mounts; do
    echo \"Unmounting \$m...\"
    $BUSYBOX umount -l \"\$m\" 2>/dev/null
done
"

# Release Android Wakelock
termux-wake-unlock 2>/dev/null

echo -e "\e[1;32m[✓] All sessions terminated. Memory freed.\e[0m"
