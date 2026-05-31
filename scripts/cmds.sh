#!/bin/bash
# --- OS MISSION CONTROL v16.2 ---
set -euo pipefail

REPO="$HOME/Systemless-Host-Termux-SU"
DEBIANPATH="/data/local/tmp/chrootDebian"
SCRIPTDIR="$REPO/scripts"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

if [ ! -d "$SCRIPTDIR" ]; then
  echo "[!] Script directory not found: $SCRIPTDIR" >&2
  exit 1
fi
if [ ! -d "$DEBIANPATH" ]; then
  echo "[!] Debian chroot not found: $DEBIANPATH" >&2
  exit 1
fi

SELECTED=0
OPTIONS=(
  "LAUNCH WORKSTATION (GUI)"
  "ENTER LINUX TERMINAL (CLI)"
  "GPU/VULKAN DIAGNOSTIC"
  "SYSTEM REPAIR & CLEANUP"
  "DEBIAN DEV TOOL INSTALLER"
  "CUSTOM MESA DRIVER BUILD"
  "POWER PROFILE: PERFORMANCE"
  "POWER PROFILE: COOLDOWN"
  "RESET KERNEL BRIDGES"
  "GPU STACK AUDIT & AUTO-FIX"
  "DEBIAN MAINTENANCE (UPDATE)"
  "EXIT MISSION CONTROL"
  "FULL SYSTEM SHUTDOWN"
)
C_BOLD='\e[1m'
C_ACCENT='\e[38;5;135m'
C_CYAN='\e[38;5;39m'
C_ORANGE='\e[38;5;208m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_GRAY='\e[38;5;244m'
C_DIM='\e[2m'
NC='\e[0m'

draw_bar() {
  local perc=${1:-0}
  [[ ! "$perc" =~ ^[0-9]+$ ]] && perc=0
  [ "$perc" -gt 100 ] && perc=100
  local width=15
  local filled=$((perc * width / 100))
  local empty=$((width - filled))
  printf "${C_GRAY}[${NC}"
  printf "${C_CYAN}"
  for ((i=0; i<filled; i++)); do printf "■"; done
  printf "${C_GRAY}"
  for ((i=0; i<empty; i++)); do printf "□"; done
  printf "${C_GRAY}]${NC} %d%%" "$perc"
}

get_stats() {
  CPU_RAW=$(uptime | awk -F'load average:' '{ print $2 }' | awk -F',' '{ print $1 }' | sed 's/ //g')
  CPU_PERC=$(echo "$CPU_RAW * 12.5" | bc | cut -d. -f1 2>/dev/null || echo 0)
  [[ ! "$CPU_PERC" =~ ^[0-9]+$ ]] && CPU_PERC=0
  [ "$CPU_PERC" -gt 100 ] && CPU_PERC=100
  MEM_PERC=$(free | awk '/Mem:/ { if($2>0) printf "%d", ($3*100)/$2; else print "0" }')
  BATT_JSON=$(termux-battery-status 2>/dev/null || echo '{"percentage":0,"status":"N/A"}')
  BATT_PERC=$(echo "$BATT_JSON" | grep -oEi '"percentage": [0-9]+' | awk '{print $2}')
  BATT_STAT=$(echo "$BATT_JSON" | grep -oEi '"status": "[^"]+"' | awk -F'"' '{print $4}')
  [ -z "$BATT_PERC" ] && BATT_PERC="0"
  TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
  if [ -n "$TEMP" ]; then
    TEMP="$((TEMP/1000))°C"
  else
    TEMP="N/A"
  fi
  IP_ADDR=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' || echo "DISCONNECTED")
  STORAGE_PERC=$(df -h /data | awk 'NR==2 {print $5}' | sed 's/%//')
  [ -z "$STORAGE_PERC" ] && STORAGE_PERC="0"
  grep -qF "$DEBIANPATH" /proc/mounts 2>/dev/null && ST_DEB="${C_GREEN}CONNECTED${NC}" || ST_DEB="${C_RED}DETACHED${NC}"
  grep -q "$DEBIANPATH/sdcard" /proc/mounts 2>/dev/null && ST_SD="${C_GREEN}LINKED${NC}" || ST_SD="${C_RED}MISSING${NC}"
  [ -S "$TERMUX_TMP/.X11-unix/X0" ] && pgrep -f "termux-x11" >/dev/null && ST_X11="${C_GREEN}ACTIVE${NC}" || ST_X11="${C_RED}IDLE${NC}"
  CUR_RES=$(wm size 2>/dev/null | grep -oEi '[0-9]+x[0-9]+' | tail -n 1 || echo "1080x2340")
  command -v termux-battery-status >/dev/null && ST_API="${C_GREEN}READY${NC}" || ST_API="${C_RED}ERR${NC}"
}

render() {
  printf "\e[H\e[2J"
  get_stats
  echo -e "${C_ACCENT}${C_BOLD} ⚡ PRO-TERMUX MISSION CONTROL ${NC} ${C_DIM}| BY Ruusian5${NC}"
  echo -e "${C_DIM} ──────────────────────────────────────────────────────────────${NC}"
  printf " ${C_BOLD}CPU${NC} %-22s ${C_BOLD}MEM${NC} %-22s\n" "$(draw_bar "$CPU_PERC")" "$(draw_bar "$MEM_PERC")"
  printf " ${C_BOLD}BAT${NC} %-22s ${C_BOLD}DSK${NC} %-22s\n" "$(draw_bar "$BATT_PERC")" "$(draw_bar "$STORAGE_PERC")"
  echo -e "\n ${C_GRAY}THERMAL:${NC} $TEMP ${C_GRAY}NET:${NC} ${C_CYAN}$IP_ADDR${NC} ${C_GRAY}BATT:${NC} ${C_ORANGE}$BATT_STAT${NC}"
  echo -e " ${C_GRAY}DEBIAN:${NC} $ST_DEB ${C_GRAY}SDCARD:${NC} $ST_SD ${C_GRAY}X11:${NC} $ST_X11 ${C_GRAY}API:${NC} $ST_API"
  echo -e "${C_DIM} ──────────────────────────────────────────────────────────────${NC}"
  echo -e " ${C_BOLD}FAST-PATH ALIASES:${NC}"
  echo -e " ${C_CYAN}agy${NC}: Dashboard ${C_CYAN}res${NC}: Toggle ${C_CYAN}deb${NC}: Linux CLI ${C_CYAN}sd${NC}: Shutdown"
  echo -e " ${C_CYAN}fix${NC}: Auto-Repair ${C_CYAN}gpu${NC}: GPU Audit"
  echo -e "${C_DIM} ──────────────────────────────────────────────────────────────${NC}"
  echo -e " ${C_CYAN}Current Context:${NC} ${C_BOLD}$CUR_RES${NC}"
  echo -e "${C_DIM} ──────────────────────────────────────────────────────────────${NC}"
  echo ""
  for i in "${!OPTIONS[@]}"; do
    if [ "$i" -eq "$SELECTED" ]; then
      echo -e " ${C_BOLD}${C_ACCENT}▶ ${OPTIONS[$i]}${NC} ${C_ACCENT}◀${NC}"
    else
      echo -e " ${C_GRAY}${OPTIONS[$i]}${NC}"
    fi
  done
  echo ""
  echo -e " ${C_DIM}KEYS: [1-9,G,0] RUN | [S] SHUTDOWN | [X/Q] EXIT | [↑↓] NAV${NC}"
}

execute_selection() {
  local selection="$SELECTED"
  clear
  case "$selection" in
    0)
      echo -e "\n${C_CYAN}[System] Launching Desktop...${NC}"
      if [ ! -x "$SCRIPTDIR/startxfce4_chrootDebian.sh" ]; then
        echo "[!] Missing: $SCRIPTDIR/startxfce4_chrootDebian.sh" >&2
        return 1
      fi
      bash "$SCRIPTDIR/startxfce4_chrootDebian.sh" || sleep 2
      ;;
    1)
      if [ ! -x "$SCRIPTDIR/mount-debian.sh" ]; then
        echo "[!] Missing: $SCRIPTDIR/mount-debian.sh" >&2
        return 1
      fi
      bash "$SCRIPTDIR/mount-debian.sh"
      local cli_path="/usr/local/bin/v3-cli.sh"
      if ! su -c "test -f $cli_path"; then
        echo "[!] CLI not found in chroot: $cli_path" >&2
        return 1
      fi
      su -c "'$BUSYBOX' chroot '$DEBIANPATH' $cli_path"
      ;;
    2)
      if [ ! -x "$SCRIPTDIR/gpu-check.sh" ]; then
        echo "[!] Missing: $SCRIPTDIR/gpu-check.sh" >&2
        return 1
      fi
      bash "$SCRIPTDIR/gpu-check.sh"
      echo -e "\nPress any key..."
      read -rsn1
      ;;
    3)
      if [ ! -x "$SCRIPTDIR/repair.sh" ]; then
        echo "[!] Missing: $SCRIPTDIR/repair.sh" >&2
        return 1
      fi
      bash "$SCRIPTDIR/repair.sh"
      echo -e "\nPress any key..."
      read -rsn1
      ;;
    4)
      if [ ! -x "$SCRIPTDIR/install-tools.sh" ]; then
        echo "[!] Missing: $SCRIPTDIR/install-tools.sh" >&2
        return 1
      fi
      bash "$SCRIPTDIR/install-tools.sh"
      ;;
    5)
      if [ ! -x "$SCRIPTDIR/build-custom-mesa.sh" ]; then
        echo "[!] Missing: $SCRIPTDIR/build-custom-mesa.sh" >&2
        return 1
      fi
      bash "$SCRIPTDIR/build-custom-mesa.sh"
      ;;
    6)
      echo -e "\n${C_ORANGE}[Power] Profile: PERFORMANCE${NC}"
      for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -w "$gov" ] || continue
        su -c "echo performance > '$gov'" 2>/dev/null || true
      done
      sleep 1
      ;;
    7)
      echo -e "\n${C_CYAN}[Power] Profile: COOLDOWN${NC}"
      for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -w "$gov" ] || continue
        su -c "echo powersave > '$gov'" 2>/dev/null || true
      done
      sleep 1
      ;;
    8)
      echo -e "\n${C_RED}[System] Resetting Bridges...${NC}"
      if [ -x "$SCRIPTDIR/stop-debian.sh" ]; then
        bash "$SCRIPTDIR/stop-debian.sh" || true
      fi
      bash "$SCRIPTDIR/mount-debian.sh"
      sleep 1
      ;;
    9)
      if [ ! -x "$SCRIPTDIR/gpu-audit.sh" ]; then
        echo "[!] Missing: $SCRIPTDIR/gpu-audit.sh" >&2
        return 1
      fi
      bash "$SCRIPTDIR/gpu-audit.sh"
      echo -e "\nPress any key..."
      read -rsn1
      ;;
    10)
      if [ ! -x "$SCRIPTDIR/mount-debian.sh" ]; then
        echo "[!] Missing: $SCRIPTDIR/mount-debian.sh" >&2
        return 1
      fi
      bash "$SCRIPTDIR/mount-debian.sh"
      su -c "$BUSYBOX chroot '$DEBIANPATH' /usr/bin/sh -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; apt update && apt upgrade -y'"
      echo -e "\nFinished. Press Enter..."
      read -r
      ;;
    11)
      clear
      exit 0
      ;;
    12)
      if [ ! -x "$SCRIPTDIR/termux-system-shutdown.sh" ]; then
        echo "[!] Missing: $SCRIPTDIR/termux-system-shutdown.sh" >&2
        return 1
      fi
      bash "$SCRIPTDIR/termux-system-shutdown.sh"
      ;;
    *)
      echo -e "\n${C_RED}[!] Unknown selection: $selection${NC}"
      ;;
  esac
}

if [ "${1:-}" = "--once" ]; then
  get_stats
  render
  exit 0
fi

cleanup() {
  clear
  tput cnorm 2>/dev/null || true
  exit 0
}
trap 'cleanup' SIGINT SIGTERM EXIT
tput cnorm 2>/dev/null || true
clear
