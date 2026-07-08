#!/bin/bash
# --- PRO WORKSTATION DASHBOARD v3.1 ---
# Updated: July 8 2026 — Turnip+Zink GPU (no VirGL), App Manager added

C_BOLD='\e[1m'; C_CYAN='\e[38;5;39m'; C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'; C_ORANGE='\e[38;5;208m'; C_PURPLE='\e[38;5;141m'; NC='\e[0m'

X_SOCK="/data/data/com.termux/files/usr/tmp/.X11-unix/X0"
X_LOCK="/data/data/com.termux/files/usr/tmp/.X0-lock"
DEBIANPATH="/data/local/tmp/chrootDebian"

clean_stale() {
    X_PROC=""; pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC=1
    pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC=1
    [ -S "$X_SOCK" ] && [ -z "$X_PROC" ] && rm -f "$X_SOCK" "$X_LOCK" 2>/dev/null
}

clear
echo -e "${C_CYAN}${C_BOLD}"
echo "╔══════════════════════════════════════════════╗"
echo "║     PRO WORKSTATION DASHBOARD v3.1          ║"
echo "║        Systemless-Host-Termux-SU            ║"
echo "║        GPU: Turnip+Zink (Adreno 640)       ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

clean_stale

while true; do
    CHROOT_M=0; su -c "grep -q '/data/local/tmp/chrootDebian/dev ' /proc/mounts" 2>/dev/null && CHROOT_M=1
    CHROOT_D=0; su -c "test -d /data/local/tmp/chrootDebian/usr/bin" 2>/dev/null && CHROOT_D=1

    X_PROC=""; pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC=1
    pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC=1
    PA_R=0; pgrep -x pulseaudio >/dev/null 2>&1 && PA_R=1

    # GPU status: check Turnip+Zink (no VirGL)
    GPU_OK=0
    if [ $CHROOT_M -eq 1 ]; then
        su -c "test -e /data/local/tmp/chrootDebian/dev/kgsl-3d0" 2>/dev/null && GPU_OK=1
    fi

    if [ $CHROOT_M -eq 1 ]; then S_C="${C_GREEN}● Mounted${NC}"
    elif [ $CHROOT_D -eq 1 ]; then S_C="${C_ORANGE}○ Unmounted${NC}"
    else S_C="${C_RED}○ Missing${NC}"; fi

    if [ -S "$X_SOCK" ] && [ -n "$X_PROC" ]; then S_X="${C_GREEN}● Running${NC}"
    elif [ -S "$X_SOCK" ]; then S_X="${C_ORANGE}○ Stale socket${NC}"
    else S_X="${C_RED}○ Stopped${NC}"; fi

    S_A=$([ $PA_R -eq 1 ] && echo "${C_GREEN}● Running${NC}" || echo "${C_RED}○ Stopped${NC}")

    if [ $GPU_OK -eq 1 ]; then S_G="${C_GREEN}● Turnip+Zink${NC}"
    elif [ $CHROOT_M -eq 1 ]; then S_G="${C_RED}○ No GPU${NC}"
    else S_G="${C_ORANGE}○ N/A${NC}"; fi

    echo -e "${C_BOLD}System:${NC}  Chroot $S_C  X11 $S_X  Audio $S_A  GPU $S_G"

    echo ""
    echo -e "${C_BOLD}${C_CYAN}─── Actions ───${NC}"
    echo -e "  ${C_GREEN}[1]${NC} Start GUI      ${C_GREEN}[2]${NC} Stop GUI       ${C_GREEN}[3]${NC} Mount Chroot"
    echo -e "  ${C_GREEN}[4]${NC} Shell root     ${C_GREEN}[5]${NC} Shell ruusian  ${C_GREEN}[6]${NC} Clean & Repair"
    echo -e "  ${C_PURPLE}[7]${NC} App Manager    ${C_GREEN}[8]${NC} GPU Info       ${C_GREEN}[9]${NC} Restart GUI"
    echo ""
    echo -e "  ${C_RED}[q]${NC} Quit"
    echo ""
    echo -ne "${C_BOLD}Select: ${NC}"
    read -r opt || exit 0

    case $opt in
        1) bash ~/startxfce4_chrootDebian.sh ;;
        2) bash ~/stop-debian.sh ;;
        3) bash ~/mount-debian.sh ;;
        4) su -c "test -d /data/local/tmp/chrootDebian/usr/bin" 2>/dev/null && {
                clean_stale
                echo -e "${C_GREEN}Entering chroot as root...${NC}"
                su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/env -i HOME=/root TERM=xterm PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash -l"
           } || echo -e "${C_RED}Chroot not found${NC}" ;;
        5) su -c "test -d /data/local/tmp/chrootDebian/usr/bin" 2>/dev/null && {
                clean_stale
                echo -e "${C_GREEN}Entering chroot as ruusian...${NC}"
                su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/env -i HOME=/home/ruusian TERM=xterm PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su -l ruusian"
           } || echo -e "${C_RED}Chroot not found${NC}" ;;
        6) echo -e "${C_YELLOW}[~] Running cleanup & repair...${NC}"
           bash ~/cleanup.sh 2>/dev/null
           bash ~/repair.sh 2>/dev/null
           echo -e "${C_GREEN}[✓] Done${NC}" ;;
        7) bash ~/app-manager.sh ;;
        8) bash ~/gpu-info.sh ;;
        9) echo -e "${C_YELLOW}[~] Restarting GUI...${NC}"
           bash ~/stop-debian.sh 2>/dev/null
           sleep 2
           bash ~/startxfce4_chrootDebian.sh ;;
        q|Q) echo -e "${C_GREEN}Goodbye!${NC}"; exit 0 ;;
        r|R) clear ;;
        *) echo -e "${C_RED}Invalid${NC}"; sleep 1 ;;
    esac

    if [ "$opt" != "r" ] && [ "$opt" != "R" ]; then
        echo ""; echo -ne "${C_ORANGE}Press Enter...${NC}"; read -r || exit 0; clear
    fi
done
