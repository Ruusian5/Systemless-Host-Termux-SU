#!/bin/bash
# --- 1080P EXTERNAL MONITOR SYNC ---
echo "[+] Attempting to sync with 1080p Monitor..."
xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync 2>/dev/null
xrandr --addmode builtin "1920x1080_60.00" 2>/dev/null
xrandr --output builtin --mode 1920x1080_60.00
echo "[✓] Resolution set to 1920x1080 (16:9). Black borders should be gone."
