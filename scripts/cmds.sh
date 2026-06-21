#!/bin/bash
# --- OS MISSION CONTROL v16.1 (NEON TUI) ---
# Ultra-Performance Workstation Controller

# 1. THEME & COLORS
C_BOLD='\e[1m'
C_ACCENT='\e[38;5;135m' # Neon Purple
C_CYAN='\e[38;5;39m'   # Electric Cyan
C_ORANGE='\e[38;5;208m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_GRAY='\e[38;5;244m'
C_DIM='\e[2m'
NC='\e[0m'

DEBIANPATH="/data/local/tmp/chrootDebian"
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

# 2. DATA VISUALIZATION ENGINE
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

    read -r MEM_PERC <<< $(free | awk '/Mem:/ { if($2>0) printf "%d", ($3*100)/$2; else print "0" }')
    
    BATT_JSON=$(termux-battery-status 2>/dev/null)
    BATT_PERC=$(echo "$BATT_JSON" | grep -oEi '"percentage": [0-9]+' | awk '{print $2}')
    BATT_STAT=$(echo "$BATT_JSON" | grep -oEi '"status": "[^"]+"' | awk -F'"' '{print $4}')
    [ -z "$BATT_PERC" ] && BATT_PERC="0"
    
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    if [ -n "$TEMP" ]; then TEMP="$((TEMP/1000))°C"; else TEMP="N/A"; fi

    IP_ADDR=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
    [ -z "$IP_ADDR" ] && IP_ADDR="DISCONNECTED"

    STORAGE_PERC=$(df -h /sdcard | awk 'NR==2 {print $5}' | sed 's/%//')
    [ -z "$STORAGE_PERC" ] && STORAGE_PERC="0"

    grep -q "$DEBIANPATH" /proc/mounts 2>/dev/null && ST_DEB="${C_GREEN}CONNECTED${NC}" || ST_DEB="${C_RED}DETACHED${NC}"
    grep -q "$DEBIANPATH/sdcard" /proc/mounts 2>/dev/null && ST_SD="${C_GREEN}LINKED${NC}" || ST_SD="${C_RED}MISSING${NC}"
    [ -S "/data/data/com.termux/files/usr/tmp/.X11-unix/X0" ] && pgrep -f "termux-x11" >/dev/null && ST_X11="${C_GREEN}ACTIVE${NC}" || ST_X11="${C_RED}IDLE${NC}"
    
    CUR_RES=$(su -c "wm size" 2>/dev/null | grep -oEi '[0-9]+x[0-9]+' | tail -n 1)
    [ -z "$CUR_RES" ] && CUR_RES="1080x2340"
    
    command -v termux-battery-status >/dev/null && ST_API="${C_GREEN}READY${NC}" || ST_API="${C_RED}ERR${NC}"
}

render() {
    printf "\e[H\e[2J"
    get_stats
    
    echo -e "${C_ACCENT}${C_BOLD} ⚡ PRO-TERMUX MISSION CONTROL v0.1 ${NC} ${C_DIM}| BY RUUSIAN${NC}"
    echo -e "${C_DIM} ──────────────────────────────────────────────────────────────${NC}"
    
    printf "  ${C_BOLD}CPU${NC}  %-22s  ${C_BOLD}MEM${NC}  %-22s\n" "$(draw_bar $CPU_PERC)" "$(draw_bar $MEM_PERC)"
    printf "  ${C_BOLD}BAT${NC}  %-22s  ${C_BOLD}DSK${NC}  %-22s\n" "$(draw_bar $BATT_PERC)" "$(draw_bar $STORAGE_PERC)"
    
    echo -e "\n  ${C_GRAY}THERMAL:${NC} $TEMP  ${C_GRAY}NET:${NC} ${C_CYAN}$IP_ADDR${NC}  ${C_GRAY}BATT:${NC} ${C_ORANGE}$BATT_STAT${NC}"
    echo -e "  ${C_GRAY}DEBIAN:${NC} $ST_DEB  ${C_GRAY}SDCARD:${NC} $ST_SD  ${C_GRAY}X11:${NC} $ST_X11  ${C_GRAY}API:${NC} $ST_API"
    echo -e "${C_DIM} ──────────────────────────────────────────────────────────────${NC}"
    
    echo -e "  ${C_BOLD}FAST-PATH ALIASES:${NC}"
    echo -e "  ${C_CYAN}agy${NC}: Dashboard  ${C_CYAN}res${NC}: 2K Toggle  ${C_CYAN}deb${NC}: Linux CLI  ${C_CYAN}sd${NC}: Shutdown"
    echo -e "  ${C_CYAN}fix${NC}: Auto-Repair  ${C_CYAN}gpu${NC}: GPU Audit"
    echo -e "${C_DIM} ──────────────────────────────────────────────────────────────${NC}"

    echo -e "  ${C_CYAN}Current Context:${NC} ${C_BOLD}$CUR_RES${NC} @ ${C_BOLD}ADRENO-640${NC}"
    echo -e "${C_DIM} ──────────────────────────────────────────────────────────────${NC}"
    echo ""

    for i in "${!OPTIONS[@]}"; do
        if [ $i -eq $SELECTED ]; then
            echo -e "  ${C_BOLD}${C_ACCENT}▶ ${OPTIONS[$i]}${NC} ${C_ACCENT}◀${NC}"
        else
            echo -e "    ${C_GRAY}${OPTIONS[$i]}${NC}"
        fi
    done
    
    echo ""
    echo -e "  ${C_DIM}KEYS: [1-9,G,0] RUN | [S] SHUTDOWN | [X/Q] EXIT | [↑↓] NAV${NC}"
}

execute_selection() {
    clear
    case $SELECTED in
        0) echo -e "\n${C_CYAN}[System] Launching Desktop...${NC}"; bash ~/startxfce4_chrootDebian.sh || sleep 2 ;;
        1) bash ~/mount-debian.sh; su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/local/bin/v3-cli.sh" ;;
        2) bash ~/gpu-check.sh; echo -e "\nPress any key..."; read -n 1 ;;
        3) bash ~/repair.sh; echo -e "\nPress any key..."; read -n 1 ;;
        4) bash ~/install-tools.sh ;;
        5) bash ~/build-custom-mesa.sh ;;
        6) echo -e "\n${C_ORANGE}[Power] Profile: PERFORMANCE${NC}"; su -c "for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > \$i; done" 2>/dev/null; sleep 1 ;;
        7) echo -e "\n${C_CYAN}[Power] Profile: COOLDOWN${NC}"; su -c "for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo powersave > \$i; done" 2>/dev/null; sleep 1 ;;
        8) echo -e "\n${C_RED}[System] Resetting Bridges...${NC}"; bash ~/stop-debian.sh && bash ~/mount-debian.sh; sleep 1 ;;
        9) bash ~/gpu-audit.sh; echo -e "\nPress any key..."; read -n 1 ;;
        10) bash ~/mount-debian.sh; su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/sh -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; apt update && apt upgrade -y'"; echo -e "\nFinished. Press Enter..."; read ;;
        11) clear; exit 0 ;;
        12) bash ~/termux-system-shutdown.sh ;;
    esac
    clear
}

if [ "$1" == "--once" ]; then
    get_stats
    render
    exit 0
fi

trap 'clear; tput cnorm 2>/dev/null; exit 0' SIGINT SIGTERM EXIT
tput cnorm 2>/dev/null
clear

while true; do
    render
    read -rsn1 -t 30 key
    case "$key" in
        $'\x1b')
            read -rsn2 -t 0.05 extra
            case "$extra" in
                "[A") ((SELECTED--)) ;;
                "[B") ((SELECTED++)) ;;
            esac
            ;;
        $'\n'|$'\r') execute_selection ;;
        "") : ;;
        [1-9]) SELECTED=$((key - 1)); execute_selection ;;
        [gG]) SELECTED=9; execute_selection ;;
        "0") SELECTED=10; execute_selection ;;
        [xX]) SELECTED=11; execute_selection ;;
        [sS]) SELECTED=12; execute_selection ;;
        [qQ]) clear; exit 0 ;;
    esac
    if [ $SELECTED -lt 0 ]; then SELECTED=$((${#OPTIONS[@]} - 1)); fi
    if [ $SELECTED -ge ${#OPTIONS[@]} ]; then SELECTED=0; fi
done
