#!/data/data/com.termux/files/usr/bin/bash
# Toggle between Native and HDMI display modes
set -euo pipefail

WM_CMD="wm"
if ! command -v wm >/dev/null 2>&1; then
  WM_CMD="/system/bin/wm"
fi

# Detect physical values (use reset first to clear overrides)
PHYS_SIZE=$($WM_CMD size 2>/dev/null | grep 'Physical' | grep -oE '[0-9]+x[0-9]+' || echo "1080x2340")
PHYS_DENSITY=$($WM_CMD density 2>/dev/null | grep 'Physical' | grep -oE '[0-9]+' || echo "401")
OVERRIDE_SIZE=$($WM_CMD size 2>/dev/null | grep 'Override' | grep -oE '[0-9]+x[0-9]+' || echo "")
OVERRIDE_DENSITY=$($WM_CMD density 2>/dev/null | grep 'Override' | grep -oE '[0-9]+' || echo "")

HDMI_SIZE="1080x1920"
HDMI_DENSITY="137"

# Determine current mode
if [ -z "$OVERRIDE_SIZE" ]; then
  CURRENT_MODE="native"
elif [ "$OVERRIDE_SIZE" = "$HDMI_SIZE" ] && [ "$OVERRIDE_DENSITY" = "$HDMI_DENSITY" ]; then
  CURRENT_MODE="hdmi"
else
  CURRENT_MODE="unknown"
fi

if [ "$CURRENT_MODE" = "hdmi" ]; then
  echo "[→] Switching to Native mode..."
  $WM_CMD size reset
  $WM_CMD density reset
  echo "[✓] Native mode: $PHYS_SIZE @ ${PHYS_DENSITY} DPI"
elif [ "$CURRENT_MODE" = "native" ]; then
  echo "[→] Switching to HDMI mode..."
  $WM_CMD size "$HDMI_SIZE"
  $WM_CMD density "$HDMI_DENSITY"
  echo "[✓] HDMI mode: $HDMI_SIZE @ ${HDMI_DENSITY} DPI"
else
  echo "[!] Unknown mode (size: ${OVERRIDE_SIZE:-$PHYS_SIZE}, density: ${OVERRIDE_DENSITY:-$PHYS_DENSITY})"
  echo "[i] Native: $PHYS_SIZE @ ${PHYS_DENSITY} DPI"
  echo "[i] Defaulting to HDMI..."
  $WM_CMD size "$HDMI_SIZE"
  $WM_CMD density "$HDMI_DENSITY"
  echo "[✓] HDMI mode: $HDMI_SIZE @ ${HDMI_DENSITY} DPI"
fi
