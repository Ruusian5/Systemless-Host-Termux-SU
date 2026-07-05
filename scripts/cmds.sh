#!/bin/bash
# --- PRO WORKSTATION DASHBOARD v3.0 ---
# By Ruusian — lean essential actions only

C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_ORANGE='\e[38;5;208m'
NC='\e[0m'

DEBIANPATH="/data/local/tmp/chrootDebian"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

clear
echo -e "${C_CYAN}${C_BOLD}"
echo "╔══════════════════════════════════════════╗"
echo "║     PRO WORKSTATION DASHBOARD v3.0      ║"
echo "║        Systemless-Host-Termux-SU        ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

while true; do
    if su -c "grep -q '$DEBIANPATH/dev ' /proc/mounts" 2>/dev/null; then
        CHROOT_STATUS="${C_GREEN}● Mounted${NC}"
    elif su -c "test -d $DEBIANPATH/usr/bin" 2>/dev/null; then
        CHROOT_STATUS="${C_ORANGE}○ Unmounted${NC}"
    else
        CHROOT_STATUS="${C_RED}○ Missing${NC}"
    fi

    X_PROC=""; pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC=1
    pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC=1
    if [ -S "$TERMUX_TMP/.X11-unix/X0" ] && [ -n "$X_PROC" ]; then
        X_STATUS="${C_GREEN}● Running${NC}"
    else
        X_STATUS="${C_RED}○ Stopped${NC}"
    fi

    if pgrep -x pulseaudio >/dev/null 2>&1; then
        PA_STATUS="${C_GREEN}● Running${NC}"
    else
        PA_STATUS="${C_RED}○ Stopped${NC}"
    fi

    echo
    echo -e "${C_BOLD}System Status:${NC}"
    echo -e "  Chroot:  $CHROOT_STATUS"
    echo -e "  X11:     $X_STATUS"
    echo -e "  Audio:   $PA_STATUS"
    echo
    echo -e "${C_BOLD}${C_CYAN}─── Essentials ───${NC}"
    echo -e "  ${C_GREEN}[1]${NC}  Start Desktop      ${C_GREEN}[2]${NC}  Stop All (graceful)"
    echo -e "  ${C_GREEN}[3]${NC}  Force Kill All     ${C_GREEN}[4]${NC}  Audio Restart"
    echo -e "  ${C_GREEN}[5]${NC}  Status Diagnostics"
    echo
    echo -e "${C_BOLD}${C_PURPLE}─── Shell ───${NC}"
    echo -e "  ${C_PURPLE}[6]${NC}  Login to Chroot (ruusian)"
    echo
    echo -e "  ${C_RED}[q]${NC}  Quit"
    echo
    echo -ne "${C_BOLD}Select option: ${NC}"
    read -r opt

    case $opt in
        1) bash ~/startxfce4_chrootDebian.sh ;;
        2) bash ~/stop-debian.sh ;;
        3) echo -e "${C_RED}[!] Force-killing all processes and cleaning up...${NC}"
           su -c "pkill -9 -f termux-x11" 2>/dev/null
           su -c "pkill -9 -f xfwm4" 2>/dev/null
           su -c "pkill -9 -f xfce4-panel" 2>/dev/null
           su -c "pkill -9 -f xfdesktop" 2>/dev/null
           su -c "pkill -9 -f xfsettingsd" 2>/dev/null
           su -c "pkill -9 -f xfce4-notifyd" 2>/dev/null
           su -c "pkill -9 -f xfce4-session" 2>/dev/null
           su -c "pkill -9 -f virgl_test_server" 2>/dev/null
           su -c "pkill -9 -f clipboard-sync" 2>/dev/null
           pkill -9 -f pulseaudio 2>/dev/null
           rm -f "$TERMUX_TMP"/.X0-lock "$TERMUX_TMP"/.X11-unix/X0 2>/dev/null
           rm -f "$TERMUX_TMP"/clipboard-sync.pid 2>/dev/null
           echo -e "${C_GREEN}[✓] All processes killed, stale files cleaned${NC}"
           echo -e "${C_YELLOW}[~] Unmounting chroot...${NC}"
           for mp in var/lock run dev/shm tmp data/data/com.termux/files/usr sdcard linkerconfig apex vendor system dev/pts sys proc dev; do
               su -c "/data/data/com.termux/files/usr/bin/busybox umount -l $DEBIANPATH/$mp" 2>/dev/null || true
           done
           echo -e "${C_GREEN}[✓] Unmounted${NC}" ;;
        4) bash ~/fix-audio.sh ;;
        5) bash ~/status-diagnostics.sh ;;
        6) if su -c "test -d $DEBIANPATH/usr/bin" 2>/dev/null; then
             su -c "rm -f $TERMUX_TMP/.X11-unix/X0 $TERMUX_TMP/.X0-lock" 2>/dev/null
             echo -e "${C_GREEN}Entering chroot as ruusian...${NC}"
             su -c "setenforce 0" 2>/dev/null
             su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/env -i HOME=/home/ruusian TERM=xterm PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su -l ruusian"
           else
             echo -e "${C_RED}Chroot not found at $DEBIANPATH${NC}"
           fi ;;
        r|R) clear ;;
        q|Q) echo -e "${C_GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${C_RED}Invalid option${NC}"; sleep 1 ;;
    esac

    if [ "$opt" != "r" ] && [ "$opt" != "R" ]; then
        echo
        echo -ne "${C_ORANGE}Press Enter to return to dashboard...${NC}"
        read -r
        clear
    fi
done