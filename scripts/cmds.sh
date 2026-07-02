#!/bin/bash
# --- PRO WORKSTATION DASHBOARD v2.1 ---
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
echo "║     PRO WORKSTATION DASHBOARD v2.1      ║"
echo "║        Systemless-Host-Termux-SU        ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

while true; do
    # Check chroot status (actual bind mounts, not just directory presence)
    if su -c "grep -q '/data/local/tmp/chrootDebian/dev ' /proc/mounts" 2>/dev/null; then
        CHROOT_STATUS="${C_GREEN}● Mounted${NC}"
    elif su -c "test -d /data/local/tmp/chrootDebian/usr/bin" 2>/dev/null; then
        CHROOT_STATUS="${C_ORANGE}○ Unmounted (dir only)${NC}"
    else
        CHROOT_STATUS="${C_RED}○ Missing${NC}"
    fi

    # Check X server (socket + process to detect stale sockets)
    X_PROC=""; pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC=1
    pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC=1
    if [ -S /data/data/com.termux/files/usr/tmp/.X11-unix/X0 ] && [ -n "$X_PROC" ]; then
        X_STATUS="${C_GREEN}● Running${NC}"
    elif [ -S /data/data/com.termux/files/usr/tmp/.X11-unix/X0 ]; then
        X_STATUS="${C_ORANGE}○ Stale socket${NC}"
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
    echo -e "  ${C_GREEN}[3]${NC}  Mount Chroot          ${C_GREEN}[4]${NC}  Repair & Optimize"
    echo -e "  ${C_GREEN}[5]${NC}  GPU Audit             ${C_GREEN}[6]${NC}  Start PulseAudio"
    echo -e "  ${C_GREEN}[7]${NC}  Fix Audio"
    echo ""
    echo -e "${C_BOLD}${C_PURPLE}─── Shell Access ───${NC}"
    echo -e "  ${C_PURPLE}[8]${NC}  Login as root         ${C_PURPLE}[9]${NC}  Login as ruusian"
    echo -e "  ${C_PURPLE}[10]${NC} Hermes Gateway        ${C_PURPLE}[11]${NC} Start Hermes (sudo)"
    echo ""
    echo -e "${C_BOLD}${C_ORANGE}─── Utilities ───${NC}"
    echo -e "  ${C_ORANGE}[12]${NC} Backup Chroot         ${C_ORANGE}[13]${NC} Clipboard Sync"
    echo -e "  ${C_ORANGE}[14]${NC} Clear System Cache    ${C_ORANGE}[15]${NC} Cleanup System"
    echo -e "  ${C_ORANGE}[16]${NC} Log Cleanup           ${C_ORANGE}[r]${NC}  Refresh Status"
    echo ""
    echo -e "  ${C_RED}[q]${NC}  Quit Dashboard"
    echo ""
    echo -ne "${C_BOLD}Select option: ${NC}"
    read -r opt

    case $opt in
        1) bash ~/startxfce4_chrootDebian.sh ;;
        2) bash ~/stop-debian.sh ;;
        3) bash ~/mount-debian.sh ;;
        4) bash ~/repair.sh ;;
        5) bash ~/gpu-audit.sh ;;
        6) if pulseaudio --start --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" --load="module-always-sink" 2>/dev/null; then
                echo -e "${C_GREEN}PulseAudio started${NC}"
            else
                echo -e "${C_ORANGE}PulseAudio already running or failed to start${NC}"
            fi ;;
        7) bash ~/fix-audio.sh 2>/dev/null || { pulseaudio --kill 2>/dev/null; rm -f ~/.config/pulse/*-runtime/pid 2>/dev/null; pulseaudio --start --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" --load="module-always-sink" 2>/dev/null && echo -e "${C_GREEN}PulseAudio restarted${NC}" || echo -e "${C_RED}Fix Audio failed${NC}"; } ;;
        8) if su -c "test -d /data/local/tmp/chrootDebian/usr/bin" 2>/dev/null; then
                # Clean stale X socket if no X process
                X_PROC=""; pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC=1; pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC=1
                if [ -S /data/data/com.termux/files/usr/tmp/.X11-unix/X0 ] && [ -z "$X_PROC" ]; then
                    rm -f /data/data/com.termux/files/usr/tmp/.X11-unix/X0 /data/data/com.termux/files/usr/tmp/.X0-lock 2>/dev/null
                fi
                echo -e "${C_GREEN}Entering chroot as root...${NC}"
                su -c "setenforce 0" 2>/dev/null
                su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /bin/su -l"
            else
                echo -e "${C_RED}Chroot not found at /data/local/tmp/chrootDebian${NC}"
            fi ;;
        9) if su -c "test -d /data/local/tmp/chrootDebian/usr/bin" 2>/dev/null; then
                # Clean stale X socket if no X process
                X_PROC=""; pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC=1; pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC=1
                if [ -S /data/data/com.termux/files/usr/tmp/.X11-unix/X0 ] && [ -z "$X_PROC" ]; then
                    rm -f /data/data/com.termux/files/usr/tmp/.X11-unix/X0 /data/data/com.termux/files/usr/tmp/.X0-lock 2>/dev/null
                fi
                echo -e "${C_GREEN}Entering chroot as ruusian...${NC}"
                su -c "setenforce 0" 2>/dev/null
                su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /bin/su -l ruusian"
            else
                echo -e "${C_RED}Chroot not found at /data/local/tmp/chrootDebian${NC}"
            fi ;;
        10) echo -e "${C_GREEN}Starting Hermes Gateway in background...${NC}"
            # Quick pre-flight checks
            if ! su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'test -f /home/ruusian/.hermes/hermes-agent/venv/bin/hermes'" 2>/dev/null; then
                echo -e "${C_RED}Hermes not installed. Run setup inside the chroot first.${NC}"
            elif su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'pgrep -f hermes.*gateway.run' 2>/dev/null | head -1" | grep -q .; then
                echo -e "${C_ORANGE}Hermes Gateway is already running.${NC}"
            else
                nohup su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; cd; nohup /home/ruusian/.hermes/hermes-agent/venv/bin/hermes gateway run > /home/ruusian/.hermes/logs/gateway.log 2>&1 &'" > /dev/null 2>&1 &
                sleep 1
                if su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'pgrep -f hermes.*gateway.run' 2>/dev/null | head -1" | grep -q .; then
                    echo -e "${C_GREEN}Gateway started (PID $(su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'pgrep -f hermes.*gateway.run' 2>/dev/null" | head -1)). Login as ruusian [9] and use 'hermes' for interactive chat.${NC}"
                else
                    echo -e "${C_RED}Gateway failed to start. Check /home/ruusian/.hermes/logs/gateway.log inside chroot.${NC}"
                fi
            fi ;;
        11) echo -e "${C_GREEN}Starting Hermes Gateway with sudo in background...${NC}"
            if ! su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'test -f /home/ruusian/.hermes/hermes-agent/venv/bin/hermes'" 2>/dev/null; then
                echo -e "${C_RED}Hermes not installed. Run setup inside the chroot first.${NC}"
            elif su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'pgrep -f hermes.*gateway.run' 2>/dev/null | head -1" | grep -q .; then
                echo -e "${C_ORANGE}Hermes Gateway is already running.${NC}"
            else
                nohup su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; cd; sudo nohup /home/ruusian/.hermes/hermes-agent/venv/bin/hermes gateway run > /home/ruusian/.hermes/logs/gateway.log 2>&1 &'" > /dev/null 2>&1 &
                sleep 1
                if su -c "busybox chroot /data/local/tmp/chrootDebian /bin/su - ruusian -c 'pgrep -f hermes.*gateway.run' 2>/dev/null | head -1" | grep -q .; then
                    echo -e "${C_GREEN}Gateway started (sudo). Login as ruusian [9] and use 'hermes' for interactive chat.${NC}"
                else
                    echo -e "${C_RED}Gateway failed to start. Check /home/ruusian/.hermes/logs/gateway.log inside chroot.${NC}"
                fi
            fi ;;
        12) BACKUP_FILE="/sdcard/debian-backup-manual-$(date +%Y%m%d_%H%M%S).tar"
            echo -e "${C_GREEN}Creating backup (chroot OS only, excluding bind-mounts)...${NC}"
            su -c "/data/data/com.termux/files/usr/bin/tar \
              --warning=no-file-changed \
              --exclude='dev/*' --exclude='proc/*' --exclude='sys/*' \
              --exclude='system/*' --exclude='vendor/*' --exclude='apex/*' --exclude='linkerconfig/*' \
              --exclude='sdcard/*' \
              --exclude='data/data/com.termux/*' \
              --exclude='tmp/*' \
              -cf \"$BACKUP_FILE\" -C /data/local/tmp chrootDebian" 2>&1 && echo -e "${C_GREEN}Backup saved: $BACKUP_FILE${NC}" || echo -e "${C_RED}Backup failed (see errors above)${NC}" ;;
        13) bash ~/clipboard-sync.sh & ;;
        14) su -c "sync && echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null && echo "Cache cleared";;
        15) bash ~/cleanup.sh ;;
        16) su -c "busybox chroot /data/local/tmp/chrootDebian /usr/local/bin/log-cleanup.sh" ;;
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
