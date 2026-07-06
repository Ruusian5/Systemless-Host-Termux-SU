#!/bin/bash
# Battery monitor for XFCE genmon panel plugin
# Reads status file written by termux battery-bridge.sh
# Returns text + tooltip for genmon

BAT_FILE="/tmp/battery-status"

if [ ! -f "$BAT_FILE" ]; then
    echo "🔋 ??"
    echo "---"
    echo "Battery bridge not running"
    exit 0
fi

DATA=$(cat "$BAT_FILE" 2>/dev/null || echo "{}")

# Parse flat JSON with grep/sed (no python3 dependency inside chroot)
PCT=$(echo "$DATA" | grep -o '"percentage":[0-9]*' | grep -o '[0-9]*$')
STATUS=$(echo "$DATA" | grep -o '"status":"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')
PLUGGED=$(echo "$DATA" | grep -o '"plugged":"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')
TEMP=$(echo "$DATA" | grep -o '"temperature":[0-9.]*' | grep -o '[0-9.]*$')
HEALTH=$(echo "$DATA" | grep -o '"health":"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')

# Validate
PCT="${PCT:-?}"
STATUS=$(echo "$STATUS" | tr '[:upper:]' '[:lower:]' | sed 's/_/ /g')

# Choose icon based on percentage and charging
ICON="🔋"
if [ "$PCT" = "?" ]; then
    ICON="🔋 ??"
elif [ "$PCT" -le 15 ]; then
    ICON="🪫"
elif [ "$PCT" -le 30 ]; then
    ICON="🔋⚠️"
elif [ "$PCT" -le 50 ]; then
    ICON="🔋"
elif [ "$PCT" -le 80 ]; then
    ICON="🔋"
elif [ "$PCT" -le 100 ]; then
    ICON="🔋"
fi

# Charging indicator
if echo "$PLUGGED" | grep -qi "plugged"; then
    ICON="⚡$ICON"
fi

# Full status text: icon + percentage
echo "$ICON $PCT%"

# Tooltip (second line onward = tooltip)
echo "---"
echo "Battery: $PCT%"
echo "Status: $STATUS"
echo "Plugged: $PLUGGED"
echo "Temperature: ${TEMP}°C"
echo "Health: $HEALTH"
