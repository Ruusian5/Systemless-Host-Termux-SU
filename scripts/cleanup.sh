#!/bin/bash
# System cleanup - remove stale files, old logs, temp data
echo "=== Cleanup ==="
echo "Cleaning Hermes sessions..." && rm -f /data/local/tmp/chrootDebian/home/ruusian/.hermes/sessions/*.json 2>/dev/null
echo "Cleaning /tmp..." && find /data/data/com.termux/files/usr/tmp -type f \( -name "*.log" -o -name "pulse-*" -o -name "hermes-*" \) -delete 2>/dev/null
echo "Truncating session logs..." && truncate -s 0 /data/local/tmp/chrootDebian/home/ruusian/session_debug.log 2>/dev/null
echo "Cleaning APT cache..." && su -c 'busybox chroot /data/local/tmp/chrootDebian apt-get clean' 2>/dev/null
echo "Done"
