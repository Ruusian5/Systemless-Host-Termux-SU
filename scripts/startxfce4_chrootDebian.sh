#!/bin/bash
# --- SUPER-LEVEL SESSION LAUNCHER (v0.2) ---
# Enhanced: pre-flight checks, smarter PulseAudio, startup feedback

DEBIANPATH="/data/local/tmp/chrootDebian"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

C_RED='\e[1;31m'; C_GREEN='\e[1;32m'; C_YELLOW='\e[1;33m'; C_CYAN='\e[1;36m'; C_PINK='\e[1;35m'; NC='\e[0m'

# Helper for graceful process termination
terminate_process() {
    local pattern=$1
    if pidof "$pattern" >/dev/null 2>&1; then
        killall -15 "$pattern" 2>/dev/null || true
        sleep 1
        killall -9 "$pattern" 2>/dev/null || true
    fi
}

echo -e "${C_CYAN}[System] Initializing Super-Level Hardware Sequence...${NC}"

# ── 0. PREREQUISITE CHECKS ──────────────────────────────────────────
MISSING=""
command -v termux-x11 >/dev/null 2>&1 || MISSING="$MISSING termux-x11"
command -v pulseaudio >/dev/null 2>&1 || MISSING="$MISSING pulseaudio"
command -v virgl_test_server_android >/dev/null 2>&1 || echo -e "${C_YELLOW}[!] virgl_test_server_android not found — GPU acceleration disabled${NC}"
test -f ~/mount-debian.sh || MISSING="$MISSING mount-debian.sh"
test -f ~/clipboard-sync.sh || MISSING="$MISSING clipboard-sync.sh"
if [ -n "$MISSING" ]; then
    echo -e "${C_RED}[✗] Missing prerequisites:$MISSING${NC}"
    echo -e "${C_YELLOW}  Install missing packages and try again.${NC}"
    exit 1
fi

# ── 1. KERNEL-LEVEL HANDSHAKE ───────────────────────────────────────
su -c "setenforce 0" 2>/dev/null || echo -e "${C_YELLOW}[!] SELinux check failed (Non-critical)${NC}"

terminate_process "termux-x11"
pkill -x pulseaudio 2>/dev/null || true

# Clean stale locks
rm -rf "$TERMUX_TMP"/.X0-lock "$TERMUX_TMP"/.X11-unix/X0 2>/dev/null

# ── 2. CORE ENGINES ─────────────────────────────────────────────────
# PulseAudio (only if not already running)
if ! pgrep -x pulseaudio >/dev/null 2>&1; then
    echo -e "${C_GREEN}[+] Starting High-Speed Audio...${NC}"
    pulseaudio --start --exit-idle-time=-1 \
      --load="module-native-protocol-tcp port=4713 auth-anonymous=1 auth-ip-acl=127.0.0.1" 2>/dev/null || \
      echo -e "${C_YELLOW}[!] PulseAudio start failed (non-critical)${NC}"
else
    echo -e "${C_GREEN}[✓] Audio already running${NC}"
fi

# VirGL GPU bridge (skip if binary missing)
if command -v virgl_test_server_android >/dev/null 2>&1; then
    echo -e "${C_GREEN}[+] Starting GPU Bridge (VirGL)...${NC}"
    pkill -f virgl_test_server_android 2>/dev/null || true
    nohup virgl_test_server_android --multi-clients > /dev/null 2>&1 &
    disown
else
    echo -e "${C_YELLOW}[~] Skipping VirGL GPU bridge (binary not found)${NC}"
fi

# X11 Display Server
echo -e "${C_GREEN}[+] Launching X11 Display Server...${NC}"
if am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1; then
    echo -e "${C_GREEN}  → Termux:X11 app launched${NC}"
else
    echo -e "${C_YELLOW}  → Could not auto-launch Termux:X11 app. Open it manually.${NC}"
fi
XDG_RUNTIME_DIR=${TERMUX_TMP} nohup termux-x11 :0 -ac -legacy-drawing -disable-dri3 > "$HOME/x11_server.log" 2>&1 &
disown
echo -e "${C_GREEN}  → termux-x11 server starting (log: ~/x11_server.log)${NC}"

# Fix permissions after engines settle
sleep 2
chmod 777 "$TERMUX_TMP"/.virgl_test 2>/dev/null || true
chmod 777 "$TERMUX_TMP"/.X11-unix/X0 2>/dev/null || true

# Clipboard sync
echo -e "${C_GREEN}[+] Launching Universal Clipboard Sync...${NC}"
nohup bash ~/clipboard-sync.sh > "$HOME/clipboard.log" 2>&1 &
disown

# ── 3. FAST-PATH BRIDGE ─────────────────────────────────────────────
echo -e "${C_YELLOW}[~] Mounting chroot filesystems...${NC}"
bash ~/mount-debian.sh 2>&1 | grep -v "All Bridges Verified\|Synchronizing Hardware"

# ── 4. GRAPHICS SYNC ────────────────────────────────────────────────
echo -e "${C_CYAN}[→] Waiting for X11 socket...${NC}"
COUNT=0
while [ ! -S "$TERMUX_TMP/.X11-unix/X0" ]; do
    sleep 0.5
    ((COUNT++))
    # Show a progress dot every 2 seconds
    if [ $((COUNT % 4)) -eq 0 ]; then
        echo -n "."
    fi
    if [ $COUNT -ge 40 ]; then
        echo ""
        echo -e "${C_RED}[!] Display Server timeout (20s). Check ~/x11_server.log${NC}"
        echo -e "${C_YELLOW}[~] Rolling back started services...${NC}"
        terminate_process "pulseaudio"
        pkill -f virgl_test_server_android 2>/dev/null || true
        kill %1 %2 %3 2>/dev/null || true
        exit 1
    fi
done
echo ""
chmod 777 "$TERMUX_TMP/.X11-unix/X0"
echo -e "${C_GREEN}[✓] Graphics Bridge Established.${NC}"

# ── 5. LAUNCH DESKTOP ───────────────────────────────────────────────
echo -e "${C_PINK}[🚀] Starting XFCE desktop session inside Debian chroot...${NC}"
nohup su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/local/bin/v2-launch.sh" > /dev/null 2>&1 &
disown

echo ""
echo -e "${C_GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${C_GREEN}║     DEBIAN DESKTOP IS RUNNING!          ║${NC}"
echo -e "${C_GREEN}║  Open Termux:X11 app to see your desktop ║${NC}"
echo -e "${C_GREEN}║  Or use clipboard sync for copy/paste    ║${NC}"
echo -e "${C_GREEN}╚══════════════════════════════════════════╝${NC}"
