#!/bin/bash
# Fix PulseAudio - stale PID cleanup + TCP + ALSA sink
rm -f ~/.config/pulse/*-runtime/pid 2>/dev/null || true
pulseaudio --kill 2>/dev/null || true
sleep 1
if pulseaudio --start --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" --load="module-always-sink" 2>/dev/null; then
    sleep 1
    echo "PulseAudio restarted with TCP (port 4713) + ALSA sink"
else
    echo "ERROR: PulseAudio failed to start. Is it installed? (pkg install pulseaudio)"
    exit 1
fi
