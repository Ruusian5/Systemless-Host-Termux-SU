#!/data/data/com.termux/files/usr/bin/bash
# --- ROBUST CLIPBOARD SYNC DAEMON (v2.1) ---

# Prevent multiple instances
PIDFILE="/data/data/com.termux/files/usr/tmp/clipboard-sync.pid"
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        exit 0
    fi
fi
echo $$ > "$PIDFILE"

export DISPLAY=:0
export XDG_RUNTIME_DIR=/data/data/com.termux/files/usr/tmp

# Wait for X11 socket
while [ ! -S "$XDG_RUNTIME_DIR/.X11-unix/X0" ]; do
    sleep 2
done

# Initialize state with current values
LAST_TERMUX=$(termux-clipboard-get 2>/dev/null)
LAST_X11=$(xclip -selection clipboard -o 2>/dev/null)

while true; do
    # 1. Check Android Clipboard
    CUR_TERMUX=$(termux-clipboard-get 2>/dev/null)
    
    if [ "$CUR_TERMUX" != "$LAST_TERMUX" ]; then
        # Android changed -> Update X11
        echo -n "$CUR_TERMUX" | xclip -selection clipboard -i 2>/dev/null
        echo -n "$CUR_TERMUX" | xclip -selection primary -i 2>/dev/null
        LAST_TERMUX="$CUR_TERMUX"
        LAST_X11="$CUR_TERMUX"
        sleep 1
        continue
    fi

    # 2. Check X11 Clipboard
    CUR_X11=$(xclip -selection clipboard -o 2>/dev/null)
    
    if [ "$CUR_X11" != "$LAST_X11" ]; then
        # X11 changed -> Update Android
        termux-clipboard-set "$CUR_X11" 2>/dev/null
        LAST_X11="$CUR_X11"
        LAST_TERMUX="$CUR_X11"
        sleep 1
        continue
    fi
    
    sleep 1
done
