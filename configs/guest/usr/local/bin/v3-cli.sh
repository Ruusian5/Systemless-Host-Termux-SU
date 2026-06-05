#!/bin/sh
# --- SUPER-LEVEL CLI ENTRANCE (PTY-MASTER) ---
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
mkdir -p /run/user/1000 && chown 1000:1000 /run/user/1000 && chmod 700 /run/user/1000

if command -v python3 >/dev/null 2>&1; then
  exec su - ruusian -c "/usr/bin/python3 -c 'import pty; pty.spawn(\"/bin/bash\")'"
else
  exec su - ruusian
fi
