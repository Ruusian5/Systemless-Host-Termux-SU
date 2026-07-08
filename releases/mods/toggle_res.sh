#!/bin/bash

# Configuration
T_RES="1440x2560"

# Ensure wm is accessible
WM_CMD="wm"
if [[ $EUID -ne 0 ]]; then
    echo "Note: This script usually requires root (tsu/su) or ADB permissions."
fi

if ! command -v wm >/dev/null 2>&1; then
    WM_CMD="/system/bin/wm"
fi

# Get current state
CURRENT_RES=$($WM_CMD size | grep -oEi '[0-9]+x[0-9]+' | tail -n 1)
PHYSICAL_RES=$($WM_CMD size | grep -oEi '[0-9]+x[0-9]+' | head -n 1)

if [ "$CURRENT_RES" == "$T_RES" ]; then
    echo "Current resolution is 1440x2560. Resetting to default ($PHYSICAL_RES)..."
    $WM_CMD size reset
else
    echo "Switching to 1440x2560 (Current: $CURRENT_RES)..."
    $WM_CMD size "$T_RES"
fi
