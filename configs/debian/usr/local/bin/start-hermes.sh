#!/bin/bash
# --- HERMES SERVICE SIMULATOR ---
# Since chroot cannot run Systemd, this script keeps the gateway alive.

LOGFILE="/home/Ruusian5/hermes_gateway.log"

echo "[+] Starting Hermes Gateway Service..."
while true; do
    echo "[$(date)] Launching Gateway..." >> "$LOGFILE"
    /home/Ruusian5/.hermes/hermes-agent/venv/bin/hermes gateway run >> "$LOGFILE" 2>&1
    echo "[!] Gateway crashed. Restarting in 5s..." >> "$LOGFILE"
    sleep 5
done &
disown
echo "[✓] Hermes Gateway is now running in the background."
echo "Monitor logs at: tail -f ~/hermes_gateway.log"
