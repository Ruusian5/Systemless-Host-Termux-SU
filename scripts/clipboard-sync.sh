#!/bin/bash
# Clipboard sync daemon - bidirectional Android <-> X11
PIDFILE="/data/data/com.termux/files/usr/tmp/clipboard-sync.pid"
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Already running (PID $OLD_PID)"
        exit 0
    fi
    rm -f "$PIDFILE"
fi
echo $$ > "$PIDFILE"
# Clean PID on exit
trap "rm -f $PIDFILE" EXIT

export DISPLAY=:0
export XDG_RUNTIME_DIR=/data/data/com.termux/files/usr/tmp

# Wait for X11
while [ ! -S "$XDG_RUNTIME_DIR/.X11-unix/X0" ]; do sleep 2; done

# Check for xclip
if ! command -v xclip >/dev/null 2>&1; then
    echo "xclip not found - install with: apt install xclip"
    exit 1
fi

LAST_TERMUX=$(termux-clipboard-get 2>/dev/null)
LAST_X11=$(xclip -selection clipboard -o 2>/dev/null)
while true; do
    CUR_TERMUX=$(termux-clipboard-get 2>/dev/null)
    [ "$CUR_TERMUX" != "$LAST_TERMUX" ] && [ -n "$CUR_TERMUX" ] && {
        echo -n "$CUR_TERMUX" | xclip -selection clipboard -i 2>/dev/null
        echo -n "$CUR_TERMUX" | xclip -selection primary -i 2>/dev/null
        LAST_TERMUX="$CUR_TERMUX"; LAST_X11="$CUR_TERMUX"; sleep 1; continue
    }
    CUR_X11=$(xclip -selection clipboard -o 2>/dev/null)
    [ "$CUR_X11" != "$LAST_X11" ] && [ -n "$CUR_X11" ] && {
        termux-clipboard-set "$CUR_X11" 2>/dev/null
        LAST_X11="$CUR_X11"; LAST_TERMUX="$CUR_X11"; sleep 1; continue
    }
    sleep 1
done
