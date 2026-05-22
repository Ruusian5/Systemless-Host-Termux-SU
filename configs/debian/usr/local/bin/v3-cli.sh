#!/bin/sh
# --- DEBIAN CLI ROOT ENTRANCE (PATH-FIXED) ---
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
mkdir -p /run/user/1000
chown 1000:1000 /run/user/1000
chmod 700 /run/user/1000
exec /usr/bin/su - ruusian -c /usr/local/bin/cli-init.sh
