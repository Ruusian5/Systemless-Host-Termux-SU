#!/bin/bash
# --- PRO WORKSTATION DASHBOARD v2.0 ---
# By Ruusian

C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_ORANGE='\e[38;5;208m'
C_PURPLE='\e[38;5;141m'
NC='\e[0m'

clear
echo -e "${C_CYAN}${C_BOLD}"
echo "╔══════════════════════════════════════════╗"
echo "║     PRO WORKSTATION DASHBOARD v2.0      ║"
echo "║        Systemless-Host-Termux-SU        ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

while true; do
    # Check chroot status
    if # Require root - using su -c "test -d /data/local/tmp/chrootDebian/usr/bin" 2>/dev/null; then
        CHROOT_STATUS="${C_GREEN}● Mounted${NC}"
    else
        CHROOT_STATUS="${C_RED}○ Unmounted${NC}"
    fi
    
    # Check X server
    if [ -S /data/data/com.termux/files/usr/tmp/.X11-unix/X0 ] 2>/dev/null; then
        X_STATUS="${C_GREEN}● Running${NC}"
    else
        X_STATUS="${C_RED}○ Stopped${NC}"
    fi

    # Check PulseAudio
    if pgrep -x pulseaudio >/dev/null 2>&1; then
        PA_STATUS="${C_GREEN}● Running${NC}"
    else
        PA_STATUS="${C_RED}○ Stopped${NC}"
    fi

    echo -e "${C_BOLD}System Status:${NC}"
    echo -e "  Chroot:  $CHROOT_STATUS"
    echo -e "  X11:     $X_STATUS"
    echo -e "  Audio:   $PA_STATUS"
    echo ""
    echo -e "${C_BOLD}${C_CYAN}─── Quick Actions ───${NC}"
    echo -e "  ${C_GREEN}[1]${NC}  Start GUI Desktop     ${C_GREEN}[2]${NC}  Stop GUI"
    echo -e "  ${C_GREEN}[3]${NC}  Mount Chroot          ${C_GREEN}[4]${NC}  Unmount Chroot"
    echo -e "  ${C_GREEN}[5]${NC}  Repair & Optimize     ${C_GREEN}[6]${NC}  GPU Audit"
    echo -e "  ${C_GREEN}[7]${NC}  Start PulseAudio      ${C_GREEN}[8]${NC}  Fix Audio"
    echo ""
    echo -e "${C_BOLD}${C_PURPLE}─── Shell Access ───${NC}"
    echo -e "  ${C_PURPLE}[9]${NC}  Login as root         ${C_PURPLE}[10]${NC} Login as ruusian"
    echo -e "  ${C_PURPLE}[11]${NC} Hermes Gateway        ${C_PURPLE}[12]${NC} Start Hermes (sudo)"
    echo ""
    echo -e "${C_BOLD}${C_ORANGE}─── Utilities ───${NC}"
    echo -e "  ${C_ORANGE}[13]${NC} Backup Chroot         ${C_ORANGE}[14]${NC} Clipboard Sync"
    echo -e "  ${C_ORANGE}[15]${NC} Clear System Cache    ${C_ORANGE}[r]${NC}  Refresh Status"
    echo ""
    echo -e "  ${C_RED}[q]${NC}  Quit Dashboard"
    echo ""
    echo -ne "${C_BOLD}Select option: ${NC}"
    read -r opt
    
    case $opt in
        1) bash ~/startxfce4_chrootDebian.sh ;;
        2) bash ~/stop-debian.sh ;;
        3) bash ~/mount-debian.sh ;;
        4) bash ~/stop-debian.sh ;;
        5) bash ~/repair.sh ;;
        6) bash ~/gpu-audit.sh ;;
        7) pulseaudio --start --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" --load="module-always-sink" 2>/dev/null;;
        8) bash ~/fix-audio.sh 2>/dev/null || pulseaudio --kill 2>/dev/null; rm -f ~/.config/pulse/*-runtime/pid; pulseaudio --start --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" --load="module-always-sink" 2>/dev/null;;
        9) # Require root - using su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /bin/su -l" ;;
        10) # Require root - using su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /bin/su -l ruusian" ;;
        11) echo -e "${C_GREEN}Starting Hermes Gateway in background...${NC}"
            nohup su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; cd; nohup /home/ruusian/.hermes/hermes-agent/venv/bin/hermes gateway run > /home/ruusian/.hermes/logs/gateway.log 2>&1 &'" > /dev/null 2>&1 &
            echo -e "${C_GREEN}Gateway started. Login as ruusian [10] and use 'hermes' for interactive chat.${NC}" ;;
        12) echo -e "${C_GREEN}Starting Hermes Gateway with sudo in background...${NC}"
            nohup su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; cd; sudo nohup /home/ruusian/.hermes/hermes-agent/venv/bin/hermes gateway run > /home/ruusian/.hermes/logs/gateway.log 2>&1 &'" > /dev/null 2>&1 &
            echo -e "${C_GREEN}Gateway started (sudo). Login as ruusian [10] and use 'hermes' for interactive chat.${NC}" ;;
        13) BACKUP_FILE="/sdcard/debian-backup-manual-$(date +%Y%m%d_%H%M%S).tar"
            echo -e "${C_GREEN}Creating backup (excluding /dev, /proc, /sys)...${NC}"
            su -c "/data/data/com.termux/files/usr/bin/tar --exclude='dev/*' --exclude='proc/*' --exclude='sys/*' -cf \"$BACKUP_FILE\" -C /data/local/tmp chrootDebian" 2>&1 && echo -e "${C_GREEN}Backup saved: $BACKUP_FILE${NC}" || echo -e "${C_RED}Backup failed${NC}" ;;
        14) bash ~/clipboard-sync.sh & ;;
        15) # Require root - using su -c "sync && echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null && echo "Cache cleared";;
        16) bash ~/cleanup.sh ;;
        17) su -c "busybox chroot /data/local/tmp/chrootDebian /usr/local/bin/log-cleanup.sh" ;;
        r|R) clear ;;
        q|Q) echo -e "${C_GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${C_RED}Invalid option${NC}"; sleep 1 ;;
    esac

    if [ "$opt" != "r" ] && [ "$opt" != "R" ]; then
        echo ""
        echo -ne "${C_ORANGE}Press Enter to return to dashboard...${NC}"
        read -r
        clear
    fi
done
