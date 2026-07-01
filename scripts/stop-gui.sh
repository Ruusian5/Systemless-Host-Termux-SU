#!/bin/bash
# Stop chroot GUI and optionally force-unmount entire Ubuntu chroot
# Usage: bash stop-gui.sh

echo "=== Stopping chroot GUI ==="

# 1. Kill the background chroot-distro process holding the GUI
PID=$(pgrep -f "start-chroot-wrapper.sh" 2>/dev/null | head -1)
if [ -n "$PID" ]; then
  echo "Killing GUI wrapper (PID $PID)..."
  kill $PID 2>/dev/null
  sleep 2
  kill -9 $PID 2>/dev/null
fi

# 2. Kill termux-x11 server
if pgrep -x "termux-x11" > /dev/null; then
  echo "Stopping termux-x11 server..."
  killall termux-x11 2>/dev/null
  sleep 1
fi

# 3. Force unmount Ubuntu chroot (kills all remaining processes inside)
echo "Unmounting Ubuntu chroot..."
su -c "/data/data/com.termux/files/usr/bin/chroot-distro unmount ubuntu -f 2>&1"
EXIT=$?

if [ $EXIT -eq 0 ]; then
  echo "=== Ubuntu chroot fully stopped ==="
else
  echo "=== WARNING: Some processes couldn'\''t be killed (kernel cgroup issue) ==="
  echo "A full device reboot may be needed to clear remaining processes."
fi
