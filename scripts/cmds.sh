#!/bin/bash
# --- MISSION CONTROL v1.0 ---

C_CYAN='\e[36m'
C_GREEN='\e[32m'
C_GRAY='\e[90m'
C_BOLD='\e[1m'
NC='\e[0m'

DEBIANPATH="/data/local/tmp/chrootDebian"

while true; do
    # Simple header
    echo ""
    echo -e "${C_BOLD}${C_CYAN}⚡ MISSION CONTROL${NC}  ${C_GRAY}| BY RUUSIAN${NC}"
    echo -e "${C_GRAY}───${NC}"

    # Single-line stats
    CPU=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
    MEM=$(free -h | awk '/Mem:/ {print $3"/"$2}')
    grep -q "$DEBIANPATH" /proc/mounts 2>/dev/null && ST="${C_GREEN}OK${NC}" || ST="${C_RED}DOWN${NC}"
    echo -e "  ${C_GRAY}CPU${NC} $CPU  ${C_GRAY}MEM${NC} $MEM  ${C_GRAY}DEBIAN${NC} $ST"
    echo -e "${C_GRAY}───${NC}"
    echo ""

    # Menu items
    echo "  ${C_BOLD}1${NC}) Launch GUI"
    echo "  ${C_BOLD}2${NC}) Terminal (CLI)"
    echo "  ${C_BOLD}3${NC}) GPU Check"
    echo "  ${C_BOLD}4${NC}) Repair"
    echo "  ${C_BOLD}5${NC}) Update Debian"
    echo "  ${C_BOLD}6${NC}) Shutdown"
    echo "  ${C_BOLD}0${NC}) Exit"
    echo ""

    # Input
    read -p "  ${C_CYAN}>${NC} " choice

    case "$choice" in
        1)
            echo -e "\n${C_GREEN}[+] Launching Desktop...${NC}"
            bash ~/startxfce4_chrootDebian.sh & disown
            sleep 2
            echo -e "${C_GREEN}  Open Termux:X11 app to see desktop${NC}"
            read -p "  Press Enter " _
            ;;
        2)
            bash ~/mount-debian.sh 2>/dev/null
            echo -e "\n${C_GREEN}[+] Entering Debian. Type 'exit' to return.${NC}"
            su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/local/bin/v3-cli.sh"
            ;;
        3)
            bash ~/gpu-check.sh
            read -p "  Press Enter " _
            ;;
        4)
            bash ~/repair.sh
            read -p "  Press Enter " _
            ;;
        5)
            bash ~/mount-debian.sh 2>/dev/null
            echo -e "\n${C_GREEN}[+] Updating Debian...${NC}"
            su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/sh -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; apt-get update 2>&1 | tail -2; apt-get upgrade -y 2>&1 | tail -3'"
            read -p "  Press Enter " _
            ;;
        6)
            bash ~/termux-system-shutdown.sh
            read -p "  Press Enter " _
            ;;
        0|q|Q)
            clear
            exit 0
            ;;
    esac
done
