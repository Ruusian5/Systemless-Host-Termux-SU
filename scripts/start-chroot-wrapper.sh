#!/bin/bash
# This script runs INSIDE the chroot as root.
# Sets up X socket, GPU access, ldconfig, drops to ruusian.

# Update library cache (needed if Mesa/DRI libs were installed manually)
/sbin/ldconfig 2>/dev/null

# Demote out of Android top-app cgroup to prevent stuck CPU spin loops
echo $$ > /dev/cpuset/cgroup.procs 2>/dev/null || true
echo $$ > /dev/stune/cgroup.procs 2>/dev/null || true

# X socket (bind mount from Termux)
/bin/mkdir -p /tmp/.X11-unix 2>/dev/null || mkdir -p /tmp/.X11-unix 2>/dev/null || true
/bin/mount --bind /data/data/com.termux/files/usr/tmp/.X11-unix /tmp/.X11-unix 2>/dev/null || true

# Ensure /dev/null is accessible by ruusian
chmod 666 /dev/null 2>/dev/null || true

# Launch desktop as ruusian
/bin/su - ruusian -c "bash /home/ruusian/start-desktop.sh"

# Keep running so parent shell doesn't kill descendants
while true; do
  sleep 3600
done
