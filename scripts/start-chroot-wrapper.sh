#!/bin/bash
# This script runs INSIDE the chroot as root.
# It sets up the X socket and drops to ruusian user.

# X socket (bind mount from Termux)
mkdir -p /tmp/.X11-unix
mount --bind /data/data/com.termux/files/usr/tmp/.X11-unix /tmp/.X11-unix 2>/dev/null

# Launch desktop as ruusian
/bin/su - ruusian -c "bash /home/ruusian/start-desktop.sh"

# Keep running so parent shell doesn't kill descendants
while true; do
  sleep 3600
done
