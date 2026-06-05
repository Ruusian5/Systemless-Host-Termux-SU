#!/bin/bash
# --- OS MISSION CONTROL v20 ---
set -uo pipefail

REPO="$HOME/Systemless-Host-Termux-SU"
DEBIANPATH="/data/local/tmp/chrootDebian"
SCRIPTDIR="$REPO/bin"
BUSYBOX="/data/data/com.termux/files/usr/bin/busybox"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

_POWER_FILE="$HOME/.power_profile"
_POWER_STATE=$(cat "$_POWER_FILE" 2>/dev/null || echo "balanced")

OPTIONS=(
  "LAUNCH WORKSTATION (GUI)"
  "ENTER LINUX TERMINAL (CLI)"
  "DEBIAN MAINTENANCE (UPDATE)"
  "POWER PROFILE (cycle)"
  "TOGGLE RESOLUTION"
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
C_YELLOW='\e[38;5;220m'
C_MAGENTA='\e[38;5;200m'
NC='\e[0m'

bar() {
  local raw=$1 w=$2 color=$3
  local pct=$raw
  [ "$pct" -lt 0 ] && pct=0
  [ "$pct" -gt 100 ] && pct=100
  local fill=$((pct * w / 100))
  local empty=$((w - fill))
  printf "${color}"
  for ((i=0; i<fill; i++)); do printf '█'; done
  printf "${C_GRAY}"
  for ((i=0; i<empty; i++)); do printf '░'; done
  printf "${NC} %3d%%" "$raw"
}

get_cpu() {
  local a_str b_str total_a idle_a total_b idle_b dtotal didle pct
  a_str=$(su -c "awk 'NR==1{for(i=2;i<=NF;i++) printf \"%s \", \$i}' /proc/stat" 2>/dev/null) || { echo 0; return; }
  [ -z "$a_str" ] && { echo 0; return; }
  sleep 0.3
  b_str=$(su -c "awk 'NR==1{for(i=2;i<=NF;i++) printf \"%s \", \$i}' /proc/stat" 2>/dev/null) || { echo 0; return; }
  [ -z "$b_str" ] && { echo 0; return; }
  total_a=0; for v in $a_str; do total_a=$((total_a + v)); done
  total_b=0; for v in $b_str; do total_b=$((total_b + v)); done
  set -- $a_str; shift 3; idle_a=${1:-0}
  set -- $b_str; shift 3; idle_b=${1:-0}
  dtotal=$((total_b - total_a))
  didle=$((idle_b - idle_a))
  if [ "$dtotal" -gt 0 ]; then
    pct=$(( (dtotal - didle) * 100 / dtotal ))
  else
    pct=0
  fi
  echo "$pct"
}

get_mem() {
  awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{if(t>0) printf "%d",(t-a)*100/t; else print 0}' /proc/meminfo 2>/dev/null || echo 0
}

get_batt() {
  local b
  if command -v jq &>/dev/null; then
    b=$(termux-battery-status 2>/dev/null | jq -r '.percentage // "0"' 2>/dev/null || echo "0")
  else
    b=$(termux-battery-status 2>/dev/null | grep -oE '"percentage": ?[0-9]+' | grep -oE '[0-9]+' || echo "0")
  fi
  echo "$b"
}

get_temp() {
  local t=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo "0")
  if [ "$t" != "0" ] && [ -n "$t" ]; then
    echo "$((t/1000)).$(((t%1000)/100))"
  else
    echo "?"
  fi
}

get_ip() {
  local ip
  ip=$(ip -4 addr show 2>/dev/null | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v 127.0.0.1 | head -1 | cut -d' ' -f2)
  echo "${ip:-disconnected}"
}

get_uptime() {
  local up=$(awk '{print int($1/86400)"d "int(($1%86400)/3600)"h "int(($1%3600)/60)"m"}' /proc/uptime 2>/dev/null)
  echo "${up:-?}"
}

get_storage() {
  local pct
  pct=$(df /data 2>/dev/null | awk 'NR>1{printf "%d", $5}' | tr -d '%')
  echo "${pct:-0}"
}

show_status() {
  local cpu=$(get_cpu)
  local mem=$(get_mem)
  local batt=$(get_batt)
  local temp=$(get_temp)
  local ip=$(get_ip)
  local up=$(get_uptime)
  local stor=$(get_storage)
  local deb_st="DETACHED"
  local pidfile="$DEBIANPATH/tmp/v2-launch.pid"
  # Read PID from host path, then check liveness inside chroot (host kill fails EPERM)
  if [ -f "$pidfile" ]; then
    local wd_pid
    wd_pid=$(cat "$pidfile" 2>/dev/null)
    if [ -n "$wd_pid" ] && su -c "chroot '$DEBIANPATH' /bin/kill -0 $wd_pid 2>/dev/null" 2>/dev/null; then
      deb_st="RUNNING"
    fi
  fi
  if [ "$deb_st" = "DETACHED" ] && grep -qF "$DEBIANPATH" /proc/mounts 2>/dev/null; then
    deb_st="CONNECTED"
  fi

  local cpu_color=$C_GREEN
  [ "$cpu" -gt 50 ] && cpu_color=$C_YELLOW
  [ "$cpu" -gt 80 ] && cpu_color=$C_RED

  local mem_color=$C_GREEN
  [ "$mem" -gt 50 ] && mem_color=$C_YELLOW
  [ "$mem" -gt 80 ] && mem_color=$C_RED

  local power_label
  case "$_POWER_STATE" in
    performance) power_label="${C_ORANGE}PERFORMANCE${NC}" ;;
    balanced)    power_label="${C_GREEN}BALANCED${NC}" ;;
    powersave)   power_label="${C_CYAN}COOLDOWN${NC}" ;;
    *)           power_label="${C_GRAY}?${NC}" ;;
  esac

  local deb_color=$C_RED
  [ "$deb_st" = "CONNECTED" ] && deb_color=$C_YELLOW
  [ "$deb_st" = "RUNNING" ] && deb_color=$C_GREEN

  echo ""
  echo -e " ${C_DIM}┌────────────────────────────────────────────────┐${NC}"
  echo -e " ${C_DIM}│${NC} ${C_BOLD}CPU${NC}  $(bar "$cpu" 20 "$cpu_color")"
  echo -e " ${C_DIM}│${NC} ${C_BOLD}MEM${NC}  $(bar "$mem" 20 "$mem_color")"
  echo -e " ${C_DIM}│${NC} ${C_BOLD}STOR${NC} $(bar "$stor" 20 "$C_CYAN")"
  echo -e " ${C_DIM}│${NC} ${C_BOLD}BAT${NC}  $(bar "$batt" 20 "$C_CYAN")"
  echo -e " ${C_DIM}├────────────────────────────────────────────────┤${NC}"
  echo -e " ${C_DIM}│${NC} ${C_BOLD}IP${NC}     ${ip}"
  echo -e " ${C_DIM}│${NC} ${C_BOLD}TEMP${NC}   ${temp}°C"
  echo -e " ${C_DIM}│${NC} ${C_BOLD}UPTIME${NC} ${up}"
  echo -e " ${C_DIM}│${NC} ${C_BOLD}POWER${NC}  ${power_label}"
  echo -e " ${C_DIM}│${NC} ${C_BOLD}DEBIAN${NC} ${deb_color}${deb_st}${NC}"
  echo -e " ${C_DIM}└────────────────────────────────────────────────┘${NC}"
}

show_menu() {
  clear
  echo ""
  echo -e "  ${C_ACCENT}${C_BOLD}⚡ OS MISSION CONTROL v$VERSION${NC}   ${C_DIM}Systemless Host${NC}"
  echo -e "  ${C_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  show_status
  echo ""
  for i in "${!OPTIONS[@]}"; do
    printf "  ${C_CYAN}[%d]${NC}  %s\n" "$i" "${OPTIONS[$i]}"
  done
  echo ""
  echo -e "  ${C_DIM}[q/x]  Exit${NC}"
  echo ""
}

run_selection() {
  case "$1" in
    0) bash "$SCRIPTDIR/start-gui.sh" || sleep 2 ;;
    1) bash "$SCRIPTDIR/mount-guest.sh"
       su -c "'$BUSYBOX' chroot '$DEBIANPATH' /usr/local/bin/v3-cli.sh" ;;
    2) bash "$SCRIPTDIR/mount-guest.sh"
       su -c "'$BUSYBOX' chroot '$DEBIANPATH' /usr/bin/sh -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; apt update && apt upgrade -y'"
       echo -e "\nFinished." ;;
    3)
      case "$_POWER_STATE" in
        performance)
          for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            su -c "echo schedutil > '$gov'" 2>/dev/null || true
          done
          echo "balanced" > "$_POWER_FILE"
          echo -e "${C_GREEN}[Power] → BALANCED${NC}" ;;
        balanced|*)
          for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            su -c "echo powersave > '$gov'" 2>/dev/null || true
          done
          echo "powersave" > "$_POWER_FILE"
          echo -e "${C_CYAN}[Power] → COOLDOWN${NC}" ;;
        powersave)
          for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            su -c "echo performance > '$gov'" 2>/dev/null || true
          done
          echo "performance" > "$_POWER_FILE"
          echo -e "${C_ORANGE}[Power] → PERFORMANCE${NC}" ;;
      esac
      sleep 1 ;;
    4) su -c "/data/data/com.termux/files/usr/bin/bash '$SCRIPTDIR/toggle-resolution.sh'" || true ;;
    5) bash "$SCRIPTDIR/stop-guest.sh" ;;
    *) echo -e "${C_RED}Invalid option${NC}" ;;
  esac
}

VERSION="20"

if [ $# -gt 0 ]; then
  case "$1" in
    --once) show_status; exit 0 ;;
    --version|-v) echo "OS Mission Control v$VERSION"; exit 0 ;;
    menu|--menu) ;;
    gui)     run_selection 0; exit $? ;;
    deb)     run_selection 1; exit $? ;;
    update)  run_selection 2; exit $? ;;
    power)   run_selection 3; exit $? ;;
    res)     su -c "/data/data/com.termux/files/usr/bin/bash '$SCRIPTDIR/toggle-resolution.sh'"; exit $? ;;
    sd|shutdown) run_selection 5; exit $? ;;
    fix)     bash "$SCRIPTDIR/repair.sh"; exit $? ;;
    gpu)     bash "$SCRIPTDIR/gpu-audit.sh"; exit $? ;;
    *) echo "Usage: cmds.sh [--once|--version|menu|gui|deb|update|power|res|sd|shutdown|fix|gpu]"; exit 1 ;;
  esac
fi

trap 'clear; exit 0' INT TERM EXIT

while true; do
  show_menu
  echo -en " ${C_BOLD}Enter choice: ${NC}"; read -r input
  case "$input" in
    [qQ]|[xX]) clear; exit 0 ;;
    *)
      if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 0 ] && [ "$input" -lt "${#OPTIONS[@]}" ]; then
        run_selection "$input"
      elif [ -n "$input" ]; then
        echo -e "${C_RED}Invalid:${NC} enter 0-$((${#OPTIONS[@]} - 1))"
        sleep 1
      fi
      ;;
  esac
done
