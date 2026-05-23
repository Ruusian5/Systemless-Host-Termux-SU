#!/bin/sh
# --- SUPER-LEVEL CLI ENTRANCE (PTY-MASTER) ---
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
mkdir -p /run/user/1000 && chown 1000:1000 /run/user/1000 && chmod 700 /run/user/1000

# We use Python to force a 100% clean PTY allocation. 
# This bridges the gap between Android's terminal and Debian's job control.
exec su - ruusian -c "/usr/bin/python3 -c 'import pty; pty.spawn(\"/bin/bash\")'"
