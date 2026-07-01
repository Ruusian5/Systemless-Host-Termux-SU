#!/bin/bash
# Start Ubuntu chroot GUI as user ruusian
# Run this and leave the terminal open — GUI stays alive as long as this runs.
# Usage: bash start-gui.sh

echo "=== Starting chroot GUI for user ruusian ==="
echo "(Keep this terminal open — closing it stops the desktop)"

# 1. Ensure termux-x11 server is running
if ! pgrep -x "termux-x11" > /dev/null; then
  termux-x11 :0 -ac &
  sleep 2
fi

# 2. Mount chroot filesystems (/dev, /proc, /sys, /tmp) via chroot-distro
su -c '/data/data/com.termux/files/usr/bin/chroot-distro mount ubuntu 2>&1'

# 3. Ensure /dev/null exists inside chroot (dbus-launch and nohup need it)
su -c 'mknod -m 666 /data/local/chroot-distro/ubuntu/dev/null c 1 3 2>/dev/null; chmod 666 /data/local/chroot-distro/ubuntu/dev/null 2>/dev/null'

# 4. Bind mount X socket directory into chroot (so non-root user can access it)
su -c 'mkdir -p /data/local/chroot-distro/ubuntu/tmp/.X11-unix
mount --bind /data/data/com.termux/files/usr/tmp/.X11-unix /data/local/chroot-distro/ubuntu/tmp/.X11-unix 2>/dev/null'

# 5. Copy latest scripts into chroot
su -c '
cp /data/data/com.termux/files/home/start-desktop.sh /data/local/chroot-distro/ubuntu/home/ruusian/start-desktop.sh
chmod 755 /data/local/chroot-distro/ubuntu/home/ruusian/start-desktop.sh
'

# 6. Launch desktop via direct chroot (avoids chroot-distro's child cleanup)
su -c '
chroot /data/local/chroot-distro/ubuntu /bin/su - ruusian -c "bash /home/ruusian/start-desktop.sh"
'

echo "=== Desktop stopped ==="
