#!/bin/bash
# --- UNIVERSAL CLIPBOARD SYNC DAEMON ---
# Synchronizes Termux (Android) clipboard with X11 (Debian) clipboard

export DISPLAY=:0
export XDG_RUNTIME_DIR=/data/data/com.termux/files/usr/tmp

LAST_TERMUX=""
LAST_X11=""

# Wait for X11 server to be ready before starting
while [ ! -S "$XDG_RUNTIME_DIR/.X11-unix/X0" ]; do
    sleep 2
done

echo "[+] Starting Universal Clipboard Sync..."

while true; do
    # Read Android clipboard
    CUR_TERMUX=$(termux-clipboard-get 2>/dev/null)
    
    # Read X11 clipboard
    CUR_X11=$(xclip -selection clipboard -o 2>/dev/null)
    
    if [ "$CUR_TERMUX" != "$LAST_TERMUX" ] && [ "$CUR_TERMUX" != "$CUR_X11" ]; then
        # Android changed -> update X11
        echo -n "$CUR_TERMUX" | xclip -selection clipboard -i 2>/dev/null
        # Also update PRIMARY for middle-click paste
        echo -n "$CUR_TERMUX" | xclip -selection primary -i 2>/dev/null
        LAST_TERMUX="$CUR_TERMUX"
        LAST_X11="$CUR_TERMUX"
    elif [ "$CUR_X11" != "$LAST_X11" ] && [ "$CUR_X11" != "$CUR_TERMUX" ]; then
        # X11 changed -> update Android
        termux-clipboard-set "$CUR_X11" 2>/dev/null
        LAST_X11="$CUR_X11"
        LAST_TERMUX="$CUR_X11"
    fi
    
    sleep 1
done
