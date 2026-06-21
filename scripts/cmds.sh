#!/bin/bash
# --- MISSION CONTROL v1.0 ---

C=$'\e[36m'
G=$'\e[32m'
R=$'\e[31m'
GY=$'\e[90m'
B=$'\e[1m'
N=$'\e[0m'

DEBIANPATH="/data/local/tmp/chrootDebian"

# --once mode: show status and exit (used by .bashrc startup)
if [ "$1" == "--once" ]; then
    CPU=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
    MEM=$(free -h | awk '/Mem:/ {print $3"/"$2}')
    grep -q "$DEBIANPATH" /proc/mounts 2>/dev/null && ST="OK" || ST="DOWN"
    echo "${GY}CPU $CPU | MEM $MEM | DEBIAN $ST${N}"
    exit 0
fi

while true; do
    echo ""
    echo "${B}${C}⚡ MISSION CONTROL${N}  ${GY}| BY RUUSIAN${N}"
    echo "${GY}───${N}"

    CPU=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
    MEM=$(free -h | awk '/Mem:/ {print $3"/"$2}')
    grep -q "$DEBIANPATH" /proc/mounts 2>/dev/null && ST="${G}OK${N}" || ST="${R}DOWN${N}"
    echo "  ${GY}CPU${N} $CPU  ${GY}MEM${N} $MEM  ${GY}DEBIAN${N} $ST"
    echo "${GY}───${N}"
    echo ""

    echo "  ${B}1${N}) Launch GUI"
    echo "  ${B}2${N}) Terminal (CLI)"
    echo "  ${B}3${N}) GPU Check"
    echo "  ${B}4${N}) Repair"
    echo "  ${B}5${N}) Update Debian"
    echo "  ${B}6${N}) Shutdown"
    echo "  ${B}0${N}) Exit"
    echo ""

    read -p "  ${C}>${N} " choice

    case "$choice" in
        1)
            echo ""
            echo "${G}[+] Launching Desktop...${N}"
            bash ~/startxfce4_chrootDebian.sh & disown
            sleep 2
            echo "${G}  Open Termux:X11 app to see desktop${N}"
            read -p "  Press Enter " _
            ;;
        2)
            bash ~/mount-debian.sh 2>/dev/null
            echo ""
            echo "${G}[+] Entering Debian. Type 'exit' to return.${N}"
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
            echo ""
            echo "${G}[+] Updating Debian...${N}"
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
