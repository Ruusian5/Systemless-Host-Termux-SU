#!/bin/bash
# Fix stale PulseAudio PID and restart with Android audio support
rm -f ~/.config/pulse/*-runtime/pid 2>/dev/null
pulseaudio --kill 2>/dev/null
sleep 1
pulseaudio --start --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" --load="module-always-sink" --disallow-exit --exit-idle-time=-1 2>&1
echo "PulseAudio restarted with OpenSL ES sink"
