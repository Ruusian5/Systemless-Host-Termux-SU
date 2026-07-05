#!/bin/bash
# System cleanup - remove stale files, old logs, temp data
echo "=== Cleanup ==="
echo "Cleaning Hermes sessions..." && rm -f /data/local/tmp/chrootDebian/home/ruusian/.hermes/sessions/*.json 2>/dev/null || true
echo "Cleaning /tmp..." && find /data/data/com.termux/files/usr/tmp -type f \( -name "*.log" -o -name "pulse-*" -o -name "hermes-*" \) -delete 2>/dev/null || true
if command -v truncate >/dev/null 2>&1; then
    echo "Truncating session logs..." && truncate -s 0 /data/local/tmp/chrootDebian/home/ruusian/session_debug.log 2>/dev/null || true
else
    echo "Truncating session logs..." && : > /data/local/tmp/chrootDebian/home/ruusian/session_debug.log 2>/dev/null || true
fi
echo "Cleaning APT cache..." && su -c '/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian apt-get clean' 2>/dev/null || true
echo "Done"
