#!/bin/bash
. /etc/profile.d/99-hardware-acceleration.sh

# Disable compositing explicitly
xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false 2>/dev/null

dbus-launch --exit-with-session startxfce4 > /home/ruusian/session_debug.log 2>&1
