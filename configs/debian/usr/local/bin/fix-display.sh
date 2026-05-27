#!/bin/bash
# --- 1080P 100Hz EXTERNAL MONITOR SYNC (V2) ---

echo "[+] Forcing Android System to 16:9 Aspect Ratio..."
# Change Android Resolution to standard 1080p (16:9)
su -c "wm size 1080x1920"

echo "[+] Optimizing X11 for 100Hz Monitor..."
xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync 2>/dev/null
xrandr --newmode "1920x1080_100.00"  294.50  1920 2088 2296 2672  1080 1083 1088 1102 -hsync +vsync 2>/dev/null
xrandr --addmode builtin "1920x1080_60.00" 2>/dev/null
xrandr --addmode builtin "1920x1080_100.00" 2>/dev/null

if ! xrandr --output builtin --mode 1920x1080_100.00 2>/dev/null; then
    xrandr --output builtin --mode 1920x1080_60.00
fi

echo "[✓] System and GUI synchronized to 1080p."
echo "[!] Use 'reset-display' to return to phone resolution."
