#!/bin/bash
# --- BATTERY STATUS BRIDGE (v1.0) ---
# Polls Android battery status via termux-battery-status
# Writes result to shared /tmp file for Debian desktop to read
# Also pushes Android notifications for low battery / charging events

DEBIANPATH="/data/local/tmp/chrootDebian"
PIDFILE="/data/data/com.termux/files/usr/tmp/battery-bridge.pid"

set -o noclobber
if ! echo $$ > "$PIDFILE" 2>/dev/null; then
    OLD_PID=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        exit 0
    fi
    rm -f "$PIDFILE" && echo $$ > "$PIDFILE"
fi
set +o noclobber
trap "rm -f $PIDFILE" EXIT

# Shared status file — chroot binds Termux tmp → chroot /tmp, so Debian sees this
STATUS_FILE="/data/data/com.termux/files/usr/tmp/battery-status"
LOW_BATTERY_THRESHOLD=20

LAST_PCT=""
LAST_PLUG=""

while true; do
    # Poll battery status
    BATTERY_JSON=$(termux-battery-status 2>/dev/null)
    if [ -n "$BATTERY_JSON" ]; then
        echo "$BATTERY_JSON" > "$STATUS_FILE"

        # Extract values
        PCT=$(echo "$BATTERY_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('percentage',0))" 2>/dev/null)
        PLUG=$(echo "$BATTERY_JSON"  | python3 -c "import sys,json; print(json.load(sys.stdin).get('plugged',''))" 2>/dev/null)
        STAT=$(echo "$BATTERY_JSON"  | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))" 2>/dev/null)
        TEMP=$(echo "$BATTERY_JSON"  | python3 -c "import sys,json; print(json.load(sys.stdin).get('temperature',0))" 2>/dev/null)

        ESC_PCT=$(printf '%d' "$PCT" 2>/dev/null || echo 0)
        ESC_PLUG=$(printf '%s' "$PLUG" 2>/dev/null || echo "")
        ESC_STAT=$(printf '%s' "$STAT" 2>/dev/null || echo "")
        ESC_TEMP=$(printf '%.1f' "$TEMP" 2>/dev/null || echo "0")

        # Low battery alert (only once per level drop)
        if [ "$ESC_PCT" -le "$LOW_BATTERY_THRESHOLD" ] && [ "$PCT" != "$LAST_PCT" ]; then
            termux-notification \
                --id "low-battery" \
                --title "⚠️ Battery Low" \
                --content "${ESC_PCT}% remaining — Plug in soon" \
                --priority high \
                --led-color ff0000 2>/dev/null || true
        fi

        # Charging complete alert
        if [ "$ESC_STAT" = "FULL" ] && [ "$STAT" != "$LAST_STAT" ]; then
            termux-notification \
                --id "battery-full" \
                --title "🔋 Battery Full" \
                --content "100% — Unplug to preserve battery health" \
                --priority default 2>/dev/null || true
        fi

        # Charging state change
        if [ "$ESC_PLUG" != "$LAST_PLUG" ] && [ -n "$ESC_PLUG" ]; then
            if [ "$ESC_PLUG" = "PLUGGED_AC" ] || [ "$ESC_PLUG" = "PLUGGED_USB" ]; then
                termux-notification \
                    --id "battery-charging" \
                    --title "⚡ Charging" \
                    --content "Battery at ${ESC_PCT}% — ${ESC_PLUG}" \
                    --priority default 2>/dev/null || true
            fi
        fi

        LAST_PCT="$PCT"
        LAST_PLUG="$PLUG"
        LAST_STAT="$STAT"
    fi

    sleep 60
done
