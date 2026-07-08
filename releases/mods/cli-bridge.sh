#!/bin/bash
# --- MASTER TTY ALLOCATOR ---
DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"
SCRIPT_BIN="/data/data/com.termux/files/usr/bin/script"

# We use 'script' to allocate a PTY, then 'su' to enter root, then 'chroot' into Debian.
# We pass -l to su to ensure a clean login session for 'ruusian'.
su -c "setenforce 0" 2>/dev/null
$SCRIPT_BIN -q -c "su -c \"$BUSYBOX chroot $DEBIANPATH /usr/bin/env -i HOME=/home/ruusian TERM=xterm PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/bin/su -l ruusian -c /usr/local/bin/cli-init.sh\"" /dev/null
