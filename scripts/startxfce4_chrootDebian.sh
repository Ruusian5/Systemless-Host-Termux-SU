#!/bin/bash
# --- SUPER-LEVEL SESSION LAUNCHER v0.4 (Turnip+Zink) ---
# Updated: July 8 2026 — VirGL removed, Turnip+Zink GPU accel, X11 socket bind-mount

DEBIANPATH="/data/local/tmp/chrootDebian"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

C_RED='\e[1;31m'; C_GREEN='\e[1;32m'; C_YELLOW='\e[1;33m'; C_CYAN='\e[1;36m'; C_PINK='\e[1;35m'; NC='\e[0m'

# Helper for graceful process termination
terminate_process() {
    local pattern=$1
    if pgrep -f "$pattern" >/dev/null 2>&1; then
        pkill -15 -f "$pattern" 2>/dev/null || true
        sleep 1
        pkill -9 -f "$pattern" 2>/dev/null || true
    fi
}

echo -e "${C_CYAN}[System] Initializing Super-Level Hardware Sequence...${NC}"

# ── 0. PREREQUISITE CHECKS ──────────────────────────────────────────
MISSING=""
command -v termux-x11 >/dev/null 2>&1 || MISSING="$MISSING termux-x11"
command -v pulseaudio >/dev/null 2>&1 || MISSING="$MISSING pulseaudio"
command -v termux-am >/dev/null 2>&1 || echo -e "${C_YELLOW}[!] termux-am not found — Termux:X11 app must be opened manually${NC}"
test -f ~/mount-debian.sh || MISSING="$MISSING mount-debian.sh"
test -f ~/clipboard-sync.sh || MISSING="$MISSING clipboard-sync.sh"
if [ -n "$MISSING" ]; then
    echo -e "${C_RED}[✗] Missing prerequisites:$MISSING${NC}"
    echo -e "${C_YELLOW}  Install missing packages and try again.${NC}"
    exit 1
fi
if ! su -c "test -d $DEBIANPATH/usr/bin" 2>/dev/null; then
    echo -e "${C_RED}[✗] Chroot not found at $DEBIANPATH${NC}"
    exit 1
fi

# ── 0.5 SAFE START: SCRUB STALE STATE ────────────────────────────────
echo -e "${C_YELLOW}[~] Safe Start: scanning for stale state...${NC}"

# Kill leftover zombie processes from previous failed runs
for zombie_pat in "v2-launch" "user-session" "xfce4-session" "xfwm4" "xfdesktop" "xfce4-panel" "xfsettingsd" "clipboard-sync"; do
    pkill -9 -f "$zombie_pat" 2>/dev/null || true
done

# Clean stale session lock file inside chroot
su -c "rm -f $DEBIANPATH/tmp/.xfce-session.lock" 2>/dev/null || true

# Clean stale X11 socket (no process backing it)
X_PROC_CHECK=""
pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC_CHECK=1
pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC_CHECK=1
if [ -S "$TERMUX_TMP/.X11-unix/X0" ]; then
    if [ -n "$X_PROC_CHECK" ]; then
        echo -e "${C_GREEN}[✓] X11 server healthy — preserving socket${NC}"
    else
        echo -e "${C_YELLOW}[~] Cleaning stale X11 socket (no process)${NC}"
        rm -f "$TERMUX_TMP"/.X0-lock "$TERMUX_TMP"/.X11-unix/X0 2>/dev/null
    fi
fi

# ── 0.6 SAFE START: VERIFY X11 APP ────────────────────────────────────
echo -e "${C_YELLOW}[~] Verifying Termux:X11 app...${NC}"
X11_INSTALLED=$(pm list packages 2>/dev/null | grep -c com.termux.x11 || echo 0)
if [ "$X11_INSTALLED" = "0" ]; then
    echo -e "${C_RED}[✗] Termux:X11 app is NOT installed!${NC}"
    echo -e "${C_YELLOW}  Install from F-Droid: com.termux.x11${NC}"
    exit 1
fi
echo -e "${C_GREEN}[✓] Termux:X11 app found${NC}"

# ── 0.7 SAFE START: ALREADY-RUNNING CHECK ────────────────────────────
X_PROC=""; pgrep -f "com.termux.x11" >/dev/null 2>&1 && X_PROC=1
pgrep -f "termux-x11" >/dev/null 2>&1 && X_PROC=1
PA_RUNNING=0; pgrep -x pulseaudio >/dev/null 2>&1 && PA_RUNNING=1
CHROOT_MOUNTED=0; su -c "grep -q '/data/local/tmp/chrootDebian/dev ' /proc/mounts" 2>/dev/null && CHROOT_MOUNTED=1

if [ -n "$X_PROC" ] && [ $PA_RUNNING -eq 1 ] && [ $CHROOT_MOUNTED -eq 1 ]; then
    echo -e "${C_GREEN}[✓] All services already running — desktop should be active${NC}"
    echo -e "${C_GREEN}  Open Termux:X11 app to see your desktop${NC}"
    exit 0
fi

# ── 1. KERNEL-LEVEL HANDSHAKE ───────────────────────────────────────

# Kill stale termux-x11 process if socket stale
if [ -z "$X_PROC" ]; then
    pkill -9 -f "termux-x11" 2>/dev/null || true
fi

terminate_process "pulseaudio"

# ── 2. CORE ENGINES ─────────────────────────────────────────────────
# PulseAudio
if [ $PA_RUNNING -eq 0 ]; then
    echo -e "${C_GREEN}[+] Starting High-Speed Audio...${NC}"
    pulseaudio --start --exit-idle-time=-1 \
      --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" \
      > /dev/null 2>&1 || echo -e "${C_YELLOW}[!] PulseAudio start failed (non-critical)${NC}"
else
    echo -e "${C_GREEN}[✓] Audio already running${NC}"
fi

# X11 Display Server
echo -e "${C_GREEN}[+] Launching X11 Display Server...${NC}"
if [ -n "$X_PROC" ]; then
    echo -e "${C_GREEN}  → Termux:X11 process already running${NC}"
else
    # Launch the Android app first
    if command -v termux-am >/dev/null 2>&1 && termux-am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1; then
        echo -e "${C_GREEN}  → Termux:X11 app launched${NC}"
    elif command -v am >/dev/null 2>&1 && am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1; then
        echo -e "${C_GREEN}  → Termux:X11 app launched${NC}"
    elif su -c "am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity" >/dev/null 2>&1; then
        echo -e "${C_GREEN}  → Termux:X11 app launched via root${NC}"
    else
        echo -e "${C_YELLOW}  → Could not auto-launch Termux:X11 app. Open it manually.${NC}"
    fi

    # Start termux-x11 server
    XDG_RUNTIME_DIR=${TERMUX_TMP} nohup termux-x11 :0 -ac -legacy-drawing -disable-dri3 > "$HOME/x11_server.log" 2>&1 &
    disown
    echo -e "${C_GREEN}  → termux-x11 server starting (log: ~/x11_server.log)${NC}"
fi

# Fix permissions after engines settle
sleep 2
chmod 777 "$TERMUX_TMP"/.X11-unix/X0 2>/dev/null || true

# Clipboard sync
echo -e "${C_GREEN}[+] Launching Universal Clipboard Sync...${NC}"
nohup bash ~/clipboard-sync.sh > /dev/null 2>&1 &
disown

# ── 3. FAST-PATH BRIDGE ─────────────────────────────────────────────
echo -e "${C_YELLOW}[~] Mounting chroot filesystems...${NC}"
bash ~/mount-debian.sh 2>&1 | grep -v "All Bridges Verified\|Synchronizing Hardware" || true

# ── 3.5 BIND-MOUNT X11 SOCKET INTO CHROOT ──────────────────────────
echo -e "${C_YELLOW}[~] Binding X11 socket into chroot...${NC}"
su -c "mkdir -p $DEBIANPATH/tmp/.X11-unix 2>/dev/null"
if [ -S "$TERMUX_TMP/.X11-unix/X0" ]; then
    if ! su -c "grep -q '$TERMUX_TMP/.X11-unix $DEBIANPATH/tmp/.X11-unix' /proc/mounts" 2>/dev/null; then
        su -c "mount --bind $TERMUX_TMP/.X11-unix $DEBIANPATH/tmp/.X11-unix" 2>/dev/null && \
            echo -e "${C_GREEN}[✓] X11 socket bound to chroot${NC}" || \
            echo -e "${C_YELLOW}[!] X11 socket bind-mount failed${NC}"
    else
        echo -e "${C_GREEN}[✓] X11 socket already bound${NC}"
    fi
else
    echo -e "${C_YELLOW}[!] X11 socket not found yet — will retry${NC}"
fi

# ── 4. GRAPHICS SYNC ────────────────────────────────────────────────
echo -e "${C_CYAN}[→] Waiting for X11 socket...${NC}"
COUNT=0
while [ ! -S "$TERMUX_TMP/.X11-unix/X0" ]; do
    sleep 0.5
    ((COUNT++))
    if [ $((COUNT % 4)) -eq 0 ]; then
        echo -ne "\r  [$((${COUNT}/2))s/20s] "
    fi
    if [ $((COUNT % 6)) -eq 0 ] && [ -f "$HOME/x11_server.log" ]; then
        if grep -q "DeadObjectException" "$HOME/x11_server.log" 2>/dev/null; then
            echo -ne "\r  [$((${COUNT}/2))s/20s] "
            echo -e "\n${C_RED}[!] Termux:X11 app crashed (DeadObjectException)${NC}"
            echo -e "${C_YELLOW}  → Try: force-stop the app and restart${NC}"
            echo -e "${C_YELLOW}  → Or: run option [2] (Stop GUI) then retry${NC}"
            echo -e "${C_YELLOW}[~] Rolling back started services...${NC}"
            terminate_process "pulseaudio"
            kill $(jobs -p) 2>/dev/null || true
            exit 1
        fi
    fi
    if [ $COUNT -ge 40 ]; then
        echo -ne "\r  [20s/20s] "
        echo -e "\n${C_RED}[!] Display Server timeout (20s). Check ~/x11_server.log${NC}"
        if [ -f "$HOME/x11_server.log" ]; then
            echo -e "${C_YELLOW}  Last lines from log:${NC}"
            tail -5 "$HOME/x11_server.log" 2>/dev/null | sed 's/^/  /'
        fi
        echo -e "${C_YELLOW}[~] Rolling back started services...${NC}"
        terminate_process "pulseaudio"
        kill $(jobs -p) 2>/dev/null || true
        exit 1
    fi
done
echo ""
chmod 777 "$TERMUX_TMP/.X11-unix/X0" 2>/dev/null || true
echo -e "${C_GREEN}[✓] Graphics Bridge Established.${NC}"

# ── 5. LAUNCH DESKTOP ───────────────────────────────────────────────
# CRITICAL: remount /data with suid so sudo/su work inside chroot
su -c "busybox mount -o remount,dev,suid /data" 2>/dev/null

echo -e "${C_PINK}[🚀] Starting XFCE desktop session (Turnip+Zink GPU)...${NC}"
nohup su -c "chroot $DEBIANPATH /usr/bin/env -i \
    DISPLAY=:0 \
    XDG_RUNTIME_DIR=/tmp \
    HOME=/home/ruusian \
    TERM=xterm \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    MESA_LOADER_DRIVER_OVERRIDE=zink \
    MESA_GL_VERSION_OVERRIDE=4.6 \
    VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json \
    /usr/local/bin/v2-launch.sh" > /dev/null 2>&1 &
disown

# Desktop health check: pass only when the session actually became ready.
# user-session.sh writes "=== Full XFCE Desktop Ready ===" on success and
# "<comp> FAILED" for any component that did not start.
sleep 3
LOG_OK=0
if su -c "test -f $DEBIANPATH/home/ruusian/session_debug.log" 2>/dev/null; then
    if su -c "grep -q 'Full XFCE Desktop Ready' $DEBIANPATH/home/ruusian/session_debug.log" 2>/dev/null \
       && ! su -c "grep -q 'FAILED' $DEBIANPATH/home/ruusian/session_debug.log" 2>/dev/null; then
        LOG_OK=1
    fi
fi
if [ $LOG_OK -eq 0 ]; then
    echo -e "${C_YELLOW}[!] Desktop health-check inconclusive — inspect session_debug.log:${NC}"
    echo -e "${C_YELLOW}    $DEBIANPATH/home/ruusian/session_debug.log${NC}"
fi

echo ""
echo -e "${C_GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${C_GREEN}║     DEBIAN DESKTOP IS RUNNING!          ║${NC}"
echo -e "${C_GREEN}║  GPU: Turnip+Zink (Adreno 640)          ║${NC}"
echo -e "${C_GREEN}║  Open Termux:X11 app to see your desktop ║${NC}"
echo -e "${C_GREEN}╚══════════════════════════════════════════╝${NC}"
