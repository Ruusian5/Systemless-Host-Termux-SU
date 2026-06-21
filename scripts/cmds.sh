#!/bin/bash
# --- MISSION CONTROL v2.0 ---

# ANSI codes via $'' syntax (works with plain echo)
B=$'\e[1m'
C=$'\e[36m'
G=$'\e[32m'
R=$'\e[31m'
Y=$'\e[33m'
GY=$'\e[90m'
N=$'\e[0m'

DEBIANPATH="/data/local/tmp/chrootDebian"

# ---- Stats ----
stats() {
    CPU=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
    MEM=$(free -h | awk '/Mem:/ {print $3"/"$2}')
    grep -q "$DEBIANPATH" /proc/mounts 2>/dev/null && ST="${G}OK$N" || ST="${R}DOWN$N"
    echo "  ${GY}CPU$N $CPU  ${GY}MEM$N $MEM  ${GY}DEBIAN$N $ST"
}

# ---- Options ----
opt_gui() {
    echo ""
    echo "${G}[+] Launching Desktop...$N"
    bash ~/startxfce4_chrootDebian.sh & disown
    sleep 2
    echo "${G}  Open Termux:X11 app to see the desktop$N"
    read -p "  Press Enter " _
}

opt_cli() {
    bash ~/mount-debian.sh 2>/dev/null
    echo ""
    echo "${G}[+] Debian CLI - type 'exit' to return$N"
    su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/local/bin/v3-cli.sh"
}

opt_gpu() {
    bash ~/gpu-check.sh
    read -p "  Press Enter " _
}

opt_repair() {
    bash ~/repair.sh
    read -p "  Press Enter " _
}

opt_update() {
    bash ~/mount-debian.sh 2>/dev/null
    echo ""
    echo "${G}[+] Updating Debian...$N"
    su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/sh -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; apt-get update 2>&1 | tail -2; apt-get upgrade -y 2>&1 | tail -3'"
    read -p "  Press Enter " _
}

opt_shutdown() {
    bash ~/termux-system-shutdown.sh
    read -p "  Press Enter " _
}

# ---- --once mode (for bashrc) ----
if [ "$1" = "--once" ]; then
    stats
    exit 0
fi

# ---- Main loop ----
while true; do
    echo ""
    echo "${B}${C}⚡ MISSION CONTROL$N  ${GY}| BY RUUSIAN$N"
    echo "${GY}────────────────────────────────$N"
    stats
    echo "${GY}────────────────────────────────$N"
    echo ""
    echo "  ${B}1$N) Launch GUI"
    echo "  ${B}2$N) Terminal (CLI)"
    echo "  ${B}3$N) GPU Check"
    echo "  ${B}4$N) Repair"
    echo "  ${B}5$N) Update Debian"
    echo "  ${B}6$N) Shutdown"
    echo "  ${B}0$N) Exit"
    echo ""
    read -p "  ${C}>$N " ch
    case "$ch" in
        1) opt_gui ;;
        2) opt_cli ;;
        3) opt_gpu ;;
        4) opt_repair ;;
        5) opt_update ;;
        6) opt_shutdown ;;
        0|q|Q) clear; echo ""; exit 0 ;;
    esac
done
