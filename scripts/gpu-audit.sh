#!/bin/bash
# --- ENTERPRISE GPU STACK AUDIT & AUTO-FIX (v0.1) ---
# Hardened Forensic Diagnostic Tool

set -uo pipefail

C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_ORANGE='\e[38;5;208m'
NC='\e[0m'

DEBIANPATH="/data/local/tmp/chrootDebian"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"
FAIL=0

echo -e "${C_BOLD}${C_CYAN}[GPU Audit] Initiating Hardware Forensic Scan...${NC}"

# 1. Android Host Validation
echo -ne "  [1/6] Scanning Host GPU Node... "
if [ -c /dev/kgsl-3d0 ]; then
    echo -e "${C_GREEN}FOUND (Adreno)${NC}"
else
    echo -e "${C_RED}MISSING (Software Fallback Only)${NC}"
    FAIL=1
fi

# 2. VirGL Socket Forensic
echo -ne "  [2/6] Validating VirGL Bridge... "
if [ -S "$TERMUX_TMP/.virgl_test" ]; then
    PERMS=$(stat -c "%a" "$TERMUX_TMP/.virgl_test")
    if [ "$PERMS" != "777" ]; then
        echo -e "${C_RED}LOCKED ($PERMS)${NC}"
        echo -e "      -> Applying fix: chmod 777..."
        chmod 777 "$TERMUX_TMP/.virgl_test"
    else
        echo -e "${C_GREEN}READY (777)${NC}"
    fi
else
    echo -e "${C_RED}INACTIVE${NC}"
    echo -e "      -> Recommendation: Run 'virgl_test_server_android --multi-clients &'"
    FAIL=1
fi

# 3. Guest Vulkan Forensic
echo -ne "  [3/6] Inspecting Guest Vulkan Stack... "
su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/sh -c '
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    if strings /usr/lib/aarch64-linux-gnu/libvulkan_freedreno.so | grep -q kgsl 2>/dev/null; then
        exit 0
    else
        exit 1
    fi
'" && echo -e "${C_GREEN}KGSL-CAPABLE${NC}" || { echo -e "${C_ORANGE}DRM-ONLY (Upstream)${NC}"; FAIL=1; }

# 4. Driver Logic Verification
echo -e "  [4/6] Verifying Guest Driver Paths..."
for d in zink_dri.so virtio_gpu_dri.so kgsl_dri.so swrast_dri.so; do
    if su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/sh -c 'test -f /usr/lib/aarch64-linux-gnu/dri/$d'" 2>/dev/null; then
        echo -e "      - $d: ${C_GREEN}PRESENT${NC}"
    else
        echo -e "      - $d: ${C_RED}MISSING${NC}"
    fi
done

# 5. Runtime Acceleration Test
echo -e "  [5/6] Performing Acceleration Handshake..."
if [ -S "$TERMUX_TMP/.X11-unix/X0" ]; then
    if su -c "/data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/su - ruusian -c 'export DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/1000 GALLIUM_DRIVER=virgl; timeout 5s eglinfo >/dev/null 2>&1'" 2>/dev/null; then
        echo -e "      - EGL Handshake: ${C_GREEN}SUCCESS${NC}"
    else
        echo -e "      - EGL Handshake: ${C_RED}FAILED${NC} (Check X11/VirGL logs)"
    fi
else
    echo -e "      - EGL Handshake: ${C_ORANGE}SKIPPED${NC} (X11 not running)"
fi

# 6. Final Report Generation
echo -e "\n${C_BOLD}${C_CYAN}[Forensic Report Summary]${NC}"
echo "------------------------------------------------"
echo "Target: Adreno 640 (KGSL Pipeline)"
if [ $FAIL -eq 0 ]; then
    echo -e "Status: ${C_GREEN}ALL CHECKS PASSED${NC}"
else
    echo -e "Status: ${C_ORANGE}$FAIL CHECK(S) FAILED${NC}"
fi
echo "------------------------------------------------"
