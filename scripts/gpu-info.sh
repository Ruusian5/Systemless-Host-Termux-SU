#!/bin/bash
# --- GPU INFO SCRIPT ---
# Shows Turnip+Zink GPU status for Adreno 640

C_BOLD='\e[1m'; C_GREEN='\e[38;5;82m'; C_CYAN='\e[38;5;39m'; C_RED='\e[38;5;196m'; NC='\e[0m'
DEBIANPATH="/data/local/tmp/chrootDebian"
# Ensure /data is remounted suid so chroot su/sudo works
su -c "/data/data/com.termux/files/usr/bin/busybox mount -o remount,dev,suid /data" 2>/dev/null || true

clear
echo -e "${C_CYAN}${C_BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${C_CYAN}${C_BOLD}║         GPU STATUS — Turnip+Zink        ║${NC}"
echo -e "${C_CYAN}${C_BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

# Check if chroot is mounted
CHROOT_M=0; su -c "grep -q '/data/local/tmp/chrootDebian/dev ' /proc/mounts" 2>/dev/null && CHROOT_M=1
if [ $CHROOT_M -eq 0 ]; then
    echo -e "${C_RED}[!] Chroot not mounted. Run 'Mount Chroot' first.${NC}"
    exit 1
fi

# KGSL device
echo -e "${C_BOLD}── Kernel GPU Interface ──${NC}"
su -c "cat /sys/class/kgsl/kgsl-3d0/gpu_model 2>/dev/null" && echo ""
su -c "cat /sys/class/kgsl/kgsl-3d0/gpuclk 2>/dev/null" && echo " Hz"
echo -n "GPU busy: "; su -c "cat /sys/class/kgsl/kgsl-3d0/gpubusy 2>/dev/null"
echo ""

# Turnip driver
echo -e "${C_BOLD}── Turnip Vulkan Driver ──${NC}"
su -c "ls -la $DEBIANPATH/usr/lib/aarch64-linux-gnu/libvulkan_freedreno.so 2>/dev/null" || echo -e "${C_RED}Turnip driver NOT found${NC}"

# Vulkan test
echo ""
echo -e "${C_BOLD}── Vulkan GPU Detection ──${NC}"
su -c "chroot $DEBIANPATH /bin/bash -c '
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
test -x /usr/local/bin/vk_test && /usr/local/bin/vk_test 2>&1 || echo \"vk_test not found at /usr/local/bin/vk_test\"
'" 2>&1

# Zink/OpenGL test
echo ""
echo -e "${C_BOLD}── Zink OpenGL Renderer ──${NC}"
su -c "chroot $DEBIANPATH /bin/su - ruusian -c '
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export DISPLAY=:0
export MESA_LOADER_DRIVER_OVERRIDE=zink
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
export LIBGL_DRIVERS_PATH=/usr/lib/aarch64-linux-gnu/dri
glxinfo 2>&1 | grep -i \"renderer\"
'" 2>&1

echo ""
echo -e "${C_BOLD}── EGL Status ──${NC}"
su -c "chroot $DEBIANPATH /bin/su - ruusian -c '
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export MESA_LOADER_DRIVER_OVERRIDE=zink
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
eglinfo 2>&1 | grep -i \"driver\"
'" 2>&1 | head -5

echo ""
echo -e "${C_GREEN}[✓] GPU Info complete${NC}"
