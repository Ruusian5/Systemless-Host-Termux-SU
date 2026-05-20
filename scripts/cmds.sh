#!/bin/bash
# --- COMMAND MATRIX V11 (GHOST MINIMAL + CLI) ---

C1='\e[1;38;5;208m' # Orange
C2='\e[1;38;5;39m'  # Cyan
C3='\e[1;38;5;82m'  # Green
C4='\e[1;38;5;196m' # Red
C5='\e[1;38;5;239m' # Gray
NC='\e[0m'

get_stats() {
    MEM=$(free -m | awk '/Mem:/ { printf "%d/%dMB", $3, $2 }')
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    [ -n "$TEMP" ] && TEMP="$((TEMP/1000))°C" || TEMP="N/A"
    BATT=$(timeout 1s termux-battery-status 2>/dev/null | grep -oP '(?<="percentage": )\d+')
    [ -n "$BATT" ] && BATT="${BATT}%" || BATT="N/A"
    
    # High-reliability IP detection with timeout
    IP=$(timeout 1s ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' | head -n 1)
    [ -z "$IP" ] && IP=$(ip addr show wlan0 2>/dev/null | grep -w inet | awk '{print $2}' | cut -d/ -f1 | head -n 1)
    [ -z "$IP" ] && IP="Offline"

    grep -q "/data/local/tmp/chrootDebian/proc" /proc/mounts 2>/dev/null && ST_DEB="${C3}ON${NC}" || ST_DEB="${C4}OFF${NC}"
    pgrep -f "termux-x11" >/dev/null && ST_X11="${C3}ON${NC}" || ST_X11="${C4}OFF${NC}"
    [ -c "/dev/kgsl-3d0" ] && ST_GPU="${C3}NAT${NC}" || ST_GPU="${C4}NON${NC}"
}

# Function to handle actions
run_action() {
    case $1 in
        1) bash ~/startxfce4_chrootDebian.sh ;;
        2) bash ~/stop-debian.sh; sleep 1 ;;
        3) 
            # Use the same high-performance TTY bridge logic as the alias
            ~/mount-debian.sh
            /data/data/com.termux/files/usr/bin/script -q -c "su -c \"PATH=\$PATH /data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/env -i HOME=/home/ruusian TERM=\$TERM USER=ruusian PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TMPDIR=/tmp /bin/su - ruusian\"" /dev/null
            ;;
        4) 
            ~/mount-debian.sh
            su -c "PATH=$PATH /data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TMPDIR=/tmp DEBIAN_FRONTEND=noninteractive /usr/bin/sh -c \"apt update && apt upgrade -y && apt autoremove -y && apt clean\""
            sleep 1
            ;;
        5) bash ~/install-tools.sh ;;
        6) clear; exit ;;
        *) 
            # If not a number, try executing as a command
            if [ -n "$1" ]; then
                eval "$1"
                echo -e "\n${C5}Press any key to return to HUD...${NC}"
                read -n 1 -s
            fi
            ;;
    esac
}

while true; do
    clear
    get_stats

    echo -e "${C2}┌── ${C1}MATRIX HUD v11.0${C2} ──────────────────────────────────────────┐${NC}"
    echo -e "${C2}│${NC} ${C5}CPU:${NC} $LOAD  ${C5}RAM:${NC} $MEM  ${C5}TEMP:${NC} $TEMP  ${C5}BAT:${NC} $BATT  ${C5}NET:${NC} $IP ${C2}│${NC}"
    echo -e "${C2}├───┬──────────────────────────────────────────────────────────┤${NC}"
    echo -e "${C2}│${NC} STATUS │ DEBIAN: $ST_DEB  X11: $ST_X11  GPU: $ST_GPU                             ${C2}│${NC}"
    echo -e "${C2}├───┴──────────────────────────────────────────────────────────┤${NC}"
    echo -e " ${C1}[1]${NC} LAUNCH  ${C1}[2]${NC} RESET  ${C1}[3]${NC} LINUX  ${C1}[4]${NC} MAINT  ${C1}[5]${NC} TOOLS  ${C1}[6]${NC} EXIT"
    echo -e "${C2}└──────────────────────────────────────────────────────────────┘${NC}"
    
    # One-shot mode for shell login
    if [ "$1" == "--once" ]; then
        exit 0
    fi

    echo -en "${C1}CMD > ${NC}"
    # Read with 2s timeout for live updates
    read -t 2 opt
    if [ $? -eq 0 ]; then
        run_action "$opt"
    fi
done
