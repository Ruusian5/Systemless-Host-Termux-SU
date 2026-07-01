#!/bin/bash
# Fix PulseAudio - stale PID cleanup + TCP + ALSA sink
rm -f ~/.config/pulse/*-runtime/pid 2>/dev/null
pulseaudio --kill 2>/dev/null; sleep 1
pulseaudio --start --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" --load="module-always-sink" 2>/dev/null
sleep 1
echo "PulseAudio restarted with TCP (port 4713) + OpenSL ES sink"
