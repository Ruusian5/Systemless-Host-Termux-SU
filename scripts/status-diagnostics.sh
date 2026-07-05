#!/bin/bash

C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_ORANGE='\e[38;5;208m'
NC='\e[0m'

DEBIANPATH="/data/local/tmp/chrootDebian"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

echo -e "${C_BOLD}${C_CYAN}[Status Diagnostics]${NC}"

if su -c "grep -q '$DEBIANPATH/dev ' /proc/mounts" 2>/dev/null; then
    echo -e "Chroot: ${C_GREEN}mounted${NC}"
elif su -c "test -d $DEBIANPATH/usr/bin" 2>/dev/null; then
    echo -e "Chroot: ${C_ORANGE}present, not mounted${NC}"
else
    echo -e "Chroot: ${C_RED}missing${NC}"
fi

X_PROC=""
pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC=1
pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC=1
if [ -S "$TERMUX_TMP/.X11-unix/X0" ] && [ -n "$X_PROC" ]; then
    echo -e "X11: ${C_GREEN}running${NC}"
elif [ -S "$TERMUX_TMP/.X11-unix/X0" ]; then
    echo -e "X11: ${C_ORANGE}stale socket${NC}"
else
    echo -e "X11: ${C_RED}stopped${NC}"
fi

if pgrep -x pulseaudio >/dev/null 2>&1; then
    echo -e "Audio: ${C_GREEN}running${NC}"
else
    echo -e "Audio: ${C_RED}stopped${NC}"
fi

if [ -S "$TERMUX_TMP/.virgl_test" ]; then
    echo -e "VirGL: ${C_GREEN}socket ready${NC}"
else
    echo -e "VirGL: ${C_ORANGE}inactive${NC}"
fi

echo ""
echo -e "${C_BOLD}Recent X11 log:${NC}"
if [ -f "$HOME/x11_server.log" ]; then
    tail -n 8 "$HOME/x11_server.log"
else
    echo "No x11_server.log found"
fi
