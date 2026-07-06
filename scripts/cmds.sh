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

    # Check VirGL GPU
    if pgrep -f virgl_test_server >/dev/null 2>&1 && [ -S /data/data/com.termux/files/usr/tmp/.virgl_test ]; then
        VIRGL_STATUS="${C_GREEN}● Running${NC}"
    elif [ -S /data/data/com.termux/files/usr/tmp/.virgl_test ]; then
        VIRGL_STATUS="${C_ORANGE}○ Stale socket${NC}"
    else
        VIRGL_STATUS="${C_RED}○ Stopped${NC}"
    fi

    # Check Clipboard Sync
    if pgrep -f clipboard-sync.sh >/dev/null 2>&1; then
        CLIP_STATUS="${C_GREEN}● Running${NC}"
    else
        CLIP_STATUS="${C_RED}○ Stopped${NC}"
    fi

    # Check Battery Monitor
    if [ -f /data/data/com.termux/files/usr/tmp/battery-status ]; then
        BATTERY_INFO=$(python3 -c "
import sys,json
d=json.load(open('/data/data/com.termux/files/usr/tmp/battery-status'))
print(d.get('percentage','?'), d.get('plugged','?'), d.get('status','?'))
" 2>/dev/null)
        BAT_PCT=$(echo "$BATTERY_INFO" | awk '{print $1}')
        if pgrep -f battery-bridge.sh >/dev/null 2>&1; then
            BATTERY_STATUS="${C_GREEN}● ${BAT_PCT}%${NC}"
        else
            BATTERY_STATUS="${C_ORANGE}○ ${BAT_PCT}% (stale)${NC}"
        fi
    else
        BATTERY_STATUS="${C_RED}○ N/A${NC}"
    fi

    echo -e "${C_BOLD}System Status:${NC}"
    echo -e "  Chroot:  $CHROOT_STATUS"
    echo -e "  X11:     $X_STATUS"
    echo -e "  VirGL:   $VIRGL_STATUS"
    echo -e "  Audio:   $PA_STATUS"
    echo -e "  Clipboard: $CLIP_STATUS"
    echo -e "  Battery: $BATTERY_STATUS"
    echo ""
    echo -e "${C_BOLD}${C_CYAN}─── Quick Actions ───${NC}"
    echo -e "  ${C_GREEN}[1]${NC}  Start GUI Desktop     ${C_GREEN}[2]${NC}  Stop GUI"
    echo -e "  ${C_GREEN}[3]${NC}  Mount Chroot          ${C_GREEN}[4]${NC}  System Repair"
    echo -e "  ${C_GREEN}[5]${NC}  GPU Audit             ${C_GREEN}[6]${NC}  Audio Restart/Fix"
    echo -e "  ${C_GREEN}[7]${NC}  Status Diagnostics"
    echo ""
    echo -e "${C_BOLD}${C_PURPLE}─── Shell Access ───${NC}"
    echo -e "  ${C_PURPLE}[8]${NC}  Login as root         ${C_PURPLE}[9]${NC}  Login as ruusian"
    echo ""
    echo -e "${C_BOLD}${C_ORANGE}─── Utilities ───${NC}"
    echo -e "  ${C_ORANGE}[10]${NC} Clipboard Sync        ${C_ORANGE}[11]${NC} Clear System Cache"
    echo -e "  ${C_ORANGE}[12]${NC} Cleanup System        ${C_ORANGE}[13]${NC} Toggle Battery Monitor"
    echo -e "  ${C_ORANGE}[14]${NC} Battery Status"
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
        6) bash ~/fix-audio.sh ;;
        7) bash ~/status-diagnostics.sh ;;
        8) if su -c "test -d /data/local/tmp/chrootDebian/usr/bin" 2>/dev/null; then
                # Clean stale X socket if no X process
                X_PROC=""; pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC=1; pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC=1
                if [ -S /data/data/com.termux/files/usr/tmp/.X11-unix/X0 ] && [ -z "$X_PROC" ]; then
                    rm -f /data/data/com.termux/files/usr/tmp/.X11-unix/X0 /data/data/com.termux/files/usr/tmp/.X0-lock 2>/dev/null
                fi
                echo -e "${C_GREEN}Entering chroot as root...${NC}"
                su -c "setenforce 0" 2>/dev/null
                su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/env -i HOME=/root TERM=xterm PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash -l"
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
                su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/env -i HOME=/home/ruusian TERM=xterm PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/su -l ruusian"
            else
                echo -e "${C_RED}Chroot not found at /data/local/tmp/chrootDebian${NC}"
            fi ;;
        10) bash ~/clipboard-sync.sh & ;;
        11) su -c "sync && echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null && echo "Cache cleared";;
        12) bash ~/cleanup.sh ;;
        13) if pgrep -f battery-bridge.sh >/dev/null 2>&1; then
                echo -e "${C_ORANGE}Stopping Battery Monitor...${NC}"
                kill "$(pgrep -f battery-bridge.sh)" 2>/dev/null
                rm -f /data/data/com.termux/files/usr/tmp/battery-bridge.pid 2>/dev/null
                echo -e "${C_GREEN}Battery Monitor stopped${NC}"
            else
                echo -e "${C_GREEN}Starting Battery Monitor...${NC}"
                bash ~/battery-bridge.sh &
                sleep 1
                if pgrep -f battery-bridge.sh >/dev/null 2>&1; then
                    echo -e "${C_GREEN}Battery Monitor started${NC}"
                else
                    echo -e "${C_RED}Failed to start Battery Monitor${NC}"
                fi
            fi ;;
        14) if [ -f /data/data/com.termux/files/usr/tmp/battery-status ]; then
                echo -e "${C_CYAN}Battery Status:${NC}"
                python3 -c "
import sys,json
d=json.load(open('/data/data/com.termux/files/usr/tmp/battery-status'))
pct=d.get('percentage','?')
plug=d.get('plugged','?')
stat=d.get('status','?')
temp=d.get('temperature','?')
print(f'  Level:  {pct}%')
print(f'  Plugged: {plug}')
print(f'  Status: {stat}')
print(f'  Temp:   {temp}°C')
" 2>/dev/null || echo -e "${C_RED}Error reading battery data${NC}"
            else
                echo -e "${C_RED}Battery Monitor not running. Start with [13].${NC}"
            fi ;;
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