#!/bin/bash
# --- OS MISSION CONTROL v0.3 (NEON TUI ALT-SCREEN) ---
# High-Performance Interactive Workstation Controller

# 1. THEME & COLORS
C_BOLD='\e[1m'
C_ACCENT='\e[38;5;135m' # Neon Purple
C_CYAN='\e[38;5;39m'   # Electric Cyan
C_ORANGE='\e[38;5;208m' # Power Orange
C_GREEN='\e[38;5;82m'   # Signal Green
C_RED='\e[38;5;196m'    # Alert Red
C_GRAY='\e[38;5;244m'   # UI Gray
C_DIM='\e[2m'
NC='\e[0m'

DEBIANPATH="/data/local/tmp/chrootDebian"
SELECTED=0
OPTIONS=("LAUNCH WORKSTATION" "RESET KERNEL BRIDGE" "ENTER LINUX CLI" "DEBIAN MAINTENANCE" "BUILD CUSTOM DRIVER" "EXIT MISSION CONTROL")

# 2. DATA VISUALIZATION ENGINE
draw_bar() {
    local perc=${1:-0}
    [[ ! "$perc" =~ ^[0-9]+$ ]] && perc=0
    [ "$perc" -gt 100 ] && perc=100
    
    local width=20
    local filled=$((perc * width / 100))
    local empty=$((width - filled))
    printf "["
    printf "${C_CYAN}"
    for ((i=0; i<filled; i++)); do printf "■"; done
    printf "${C_GRAY}"
    for ((i=0; i<empty; i++)); do printf "□"; done
    printf "${NC}] %d%%" "$perc"
}

get_stats() {
    # Memory Logic
    read -r MEM_PERC <<< $(free | awk '/Mem:/ { if($2>0) printf "%d", ($3*100)/$2; else print "0" }')
    
    # CPU Load
    CPU_PERC=$(uptime | awk -F'load average:' '{ print $2 }' | awk -F',' '{ print $1 }' | awk '{ printf "%d", $1 * 25 }')
    [[ ! "$CPU_PERC" =~ ^[0-9]+$ ]] && CPU_PERC=0
    [ "$CPU_PERC" -gt 100 ] && CPU_PERC=100

    # Temperature
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    if [ -n "$TEMP" ]; then
        TEMP="$((TEMP/1000))°C"
    else
        TEMP="N/A"
    fi

    # Precise Status Detection
    if grep -q "$DEBIANPATH" /proc/mounts 2>/dev/null; then
        ST_DEB="${C_GREEN}CONNECTED${NC}"
    else
        ST_DEB="${C_RED}DETACHED${NC}"
    fi

    if [ -S "/data/data/com.termux/files/usr/tmp/.X11-unix/X0" ] && pgrep -f "termux-x11" >/dev/null; then
        ST_X11="${C_GREEN}ACTIVE${NC}"
    else
        ST_X11="${C_RED}IDLE${NC}"
    fi

    if [ -c "/dev/kgsl-3d0" ]; then
        ST_GPU="${C_ORANGE}ADRENO-640${NC}"
    else
        ST_GPU="${C_RED}NO-HW${NC}"
    fi
}

# 3. RENDER ENGINE
render() {
    # Move cursor to home and clear to bottom
    printf "\e[H\e[2J"
    get_stats
    echo -e "${C_ACCENT}${C_BOLD} ⚡ PRO-TERMUX HARDEN v0.3 ${NC} ${C_DIM}| SUPER-LEVEL OS ENGINE${NC}"
    echo -e "${C_DIM} ─────────────────────────────────────────────────────────────${NC}"
    
    # Stats Row
    printf "  ${C_BOLD}CPU${NC}  %-25s  ${C_BOLD}MEM${NC}  %s\n" "$(draw_bar $CPU_PERC)" "$(draw_bar $MEM_PERC)"
    echo ""
    echo -e "  ${C_GRAY}TEMP:${NC} $TEMP  ${C_GRAY}DEBIAN:${NC} $ST_DEB  ${C_GRAY}X11:${NC} $ST_X11  ${C_GRAY}GPU:${NC} $ST_GPU"
    echo -e "${C_DIM} ─────────────────────────────────────────────────────────────${NC}"
    echo ""

    # Menu System
    for i in "${!OPTIONS[@]}"; do
        if [ $i -eq $SELECTED ]; then
            echo -e "  ${C_BOLD}${C_ACCENT}▶ ${OPTIONS[$i]}${NC} ${C_ACCENT}◀${NC}"
        else
            echo -e "    ${C_GRAY}${OPTIONS[$i]}${NC}"
        fi
    done
    
    echo ""
    echo -e "  ${C_DIM}USE ARROWS [↑↓] TO NAVIGATE | [ENTER] TO EXECUTE${NC}"
}

# 4. ACTION CONTROLLER
execute_selection() {
    tput cnorm # Restore cursor
    tput rmcup # Exit alternate screen
    clear
    case $SELECTED in
        0) 
            echo -e "\n${C_CYAN}[System] Initiating Workstation Launch...${NC}"
            bash ~/startxfce4_chrootDebian.sh || (echo -e "${C_RED}Launch Failed.${NC}"; read -n 1)
            ;;
        1) 
            echo -e "\n${C_RED}[System] Resetting Kernel Bridges...${NC}"
            bash ~/stop-debian.sh && bash ~/mount-debian.sh 
            sleep 1
            ;;
        2) 
            bash ~/mount-debian.sh
            su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/local/bin/v3-cli.sh" 
            ;;
        3) 
            bash ~/mount-debian.sh
            echo -e "\n${C_GREEN}[System] Running Infrastructure Maintenance...${NC}"
            su -c "chroot $DEBIANPATH /usr/bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin apt update && apt upgrade -y"
            echo -e "\n${C_GREEN}Finished. Press Enter...${NC}"; read
            ;;
        4) 
            bash ~/build-custom-mesa.sh 
            ;;
        5) 
            exit 0 
            ;;
    esac
    
    # After action, re-enter alternate screen and hide cursor
    tput smcup
    tput civis
    clear
}

# 5. INPUT HANDLER (Loop)
if [ "$1" == "--once" ]; then
    get_stats
    echo -e "${C_ACCENT}${C_BOLD} ⚡ PRO-TERMUX HARDEN v0.3 ${NC} ${C_DIM}| SUPER-LEVEL OS ENGINE${NC}"
    echo -e "${C_DIM} ─────────────────────────────────────────────────────────────${NC}"
    printf "  ${C_BOLD}CPU${NC}  %-25s  ${C_BOLD}MEM${NC}  %s\n" "$(draw_bar $CPU_PERC)" "$(draw_bar $MEM_PERC)"
    echo -e "  ${C_GRAY}TEMP:${NC} $TEMP  ${C_GRAY}DEBIAN:${NC} $ST_DEB  ${C_GRAY}X11:${NC} $ST_X11  ${C_GRAY}GPU:${NC} $ST_GPU"
    echo -e "${C_DIM} ─────────────────────────────────────────────────────────────${NC}"
    exit 0
fi

# Enter alternate screen buffer and hide cursor for TUI
tput smcup
tput civis

# Trap exits to ensure we always restore screen state
trap 'tput cnorm; tput rmcup; clear; exit 0' SIGINT SIGTERM EXIT

while true; do
    render
    read -rsn1 -t 2 input
    if [ $? -eq 0 ]; then
        case "$input" in
            $'\x1b') # ESC sequence
                read -rsn2 -t 0.1 input
                case "$input" in
                    "[A") ((SELECTED--)); [ $SELECTED -lt 0 ] && SELECTED=$((${#OPTIONS[@]} - 1)) ;;
                    "[B") ((SELECTED++)); [ $SELECTED -ge ${#OPTIONS[@]} ] && SELECTED=0 ;;
                esac
                ;;
            "") execute_selection ;;
            [1-6]) SELECTED=$((input - 1)); execute_selection ;;
            "q") exit 0 ;;
        esac
    fi
done
