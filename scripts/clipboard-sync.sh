#!/bin/bash
# --- CLIPBOARD SYNC DAEMON (v2.0) ---
# Bidirectional Android <-> X11 clipboard sync
# xclip runs inside Debian chroot; termux-clipboard-* on Termux host

DEBIANPATH="/data/local/tmp/chrootDebian"
PIDFILE="/data/data/com.termux/files/usr/tmp/clipboard-sync.pid"

if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Already running (PID $OLD_PID)" >> /dev/null
        exit 0
    fi
    rm -f "$PIDFILE"
fi
echo $$ > "$PIDFILE"
trap "rm -f $PIDFILE" EXIT

export DISPLAY=:0
export XDG_RUNTIME_DIR=/data/data/com.termux/files/usr/tmp

su -c "setenforce 0" 2>/dev/null

# ---- helpers: run xclip inside Debian chroot ----
_xclip() {
    su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/env -i DISPLAY=:0 XDG_RUNTIME_DIR=/tmp HOME=/home/ruusian TERM=xterm PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/bin/xclip $*" 2>/dev/null || true
}
_xclip_in() {
    su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/env -i DISPLAY=:0 XDG_RUNTIME_DIR=/tmp HOME=/home/ruusian TERM=xterm PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/bin/xclip -i $*" 2>/dev/null || true
}

# Wait for X11 socket
while [ ! -S "$XDG_RUNTIME_DIR/.X11-unix/X0" ]; do sleep 2; done

# Verify xclip is available inside chroot
su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/bin/which xclip" >/dev/null 2>&1 || {
    echo "xclip not found inside chroot - install with: apt install xclip" >&2
    exit 1
}

LAST_TERMUX=$(termux-clipboard-get 2>/dev/null)
LAST_X11=$(_xclip -o -selection clipboard)
while true; do
    CUR_TERMUX=$(termux-clipboard-get 2>/dev/null)
    if [ "$CUR_TERMUX" != "$LAST_TERMUX" ] && [ -n "$CUR_TERMUX" ]; then
        echo -n "$CUR_TERMUX" | _xclip_in -selection clipboard
        echo -n "$CUR_TERMUX" | _xclip_in -selection primary
        LAST_TERMUX="$CUR_TERMUX"; LAST_X11="$CUR_TERMUX"; sleep 1; continue
    fi
    CUR_X11=$(_xclip -o -selection clipboard)
    if [ "$CUR_X11" != "$LAST_X11" ] && [ -n "$CUR_X11" ]; then
        termux-clipboard-set "$CUR_X11" 2>/dev/null
        LAST_X11="$CUR_X11"; LAST_TERMUX="$CUR_X11"; sleep 1; continue
    fi
    sleep 1
done
