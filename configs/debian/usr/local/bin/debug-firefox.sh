#!/bin/bash
. /etc/profile.d/99-hardware-acceleration.sh
export DISPLAY=:0

echo "[+] Waiting for X Server..."
until xdpyinfo > /dev/null 2>&1; do
    sleep 1
done

echo "[+] Starting Firefox with Full GPU Debugging..."
rm -f /home/ruusian/firefox_engine.log
export NSPR_LOG_MODULES="Widget:5,MediaPlayback:5,PlatformDecoderModule:5,VideoMediaCodec:5"
exec firefox --new-instance > /home/ruusian/firefox_engine.log 2>&1
