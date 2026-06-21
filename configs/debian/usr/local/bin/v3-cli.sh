#!/bin/sh
# --- SUPER-LEVEL CLI ENTRANCE (PTY-MASTER) ---
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUUSIAN_UID=$(id -u ruusian 2>/dev/null || echo 1001)
mkdir -p /run/user/$RUUSIAN_UID && chown $RUUSIAN_UID:$RUUSIAN_UID /run/user/$RUUSIAN_UID && chmod 700 /run/user/$RUUSIAN_UID

# We use Python to force a 100% clean PTY allocation.
# This bridges the gap between Android's terminal and Debian's job control.
exec su - ruusian -c "/usr/bin/python3 -c 'import pty; pty.spawn(\"/bin/bash\")'"
