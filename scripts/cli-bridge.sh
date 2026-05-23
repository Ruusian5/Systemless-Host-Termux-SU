#!/bin/bash
# --- MASTER TTY ALLOCATOR ---
DEBIANPATH="/data/local/tmp/chrootDebian"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"
SCRIPT_BIN="/data/data/com.termux/files/usr/bin/script"

# We use 'script' to allocate a PTY, then 'su' to enter root, then 'chroot' into Debian.
# We pass -l to su to ensure a clean login session for 'ruusian'.
$SCRIPT_BIN -q -c "su -c \"$BUSYBOX chroot $DEBIANPATH /usr/bin/su -l ruusian -c /usr/local/bin/cli-init.sh\"" /dev/null
