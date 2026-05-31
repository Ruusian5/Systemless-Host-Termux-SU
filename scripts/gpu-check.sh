#!/bin/bash
# --- GPU HARDWARE ACCELERATION DIAGNOSTIC v0.1 ---
C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_ORANGE='\e[38;5;208m'
NC='\e[0m'

echo -e "${C_BOLD}${C_CYAN}[GPU Diagnostic]${NC} Scanning Hardware Pipeline..."

# 1. Check KGSL
if [ -c "/dev/kgsl-3d0" ]; then
    echo -e "  [${C_GREEN}✓${NC}] KGSL Device Node: Found (/dev/kgsl-3d0)"
else
    echo -e "  [${C_RED}✗${NC}] KGSL Device Node: Not Found (No Hardware Acceleration possible)"
fi

# 2. Check Vulkan ICD
CHROOT_ICD="/data/local/tmp/chrootDebian/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json"
if su -c "test -f $CHROOT_ICD"; then
    echo -e "  [${C_GREEN}✓${NC}] Turnip ICD Config: Found (Guest OS)"
    ICD_PATH="/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json"
else
    ICD_PATH="/data/data/com.termux/files/home/drivers/freedreno_icd.aarch64.json"
    if [ -f "$ICD_PATH" ]; then
        echo -e "  [${C_GREEN}✓${NC}] Turnip ICD Config: Found (Host drivers/)"
    else
        echo -e "  [${C_RED}✗${NC}] Turnip ICD Config: Missing"
    fi
fi

# 3. Check for VK_KHR_display bug inside chroot
echo -e "\n${C_BOLD}${C_CYAN}[Vulkan Check]${NC} Testing Physical Device Enumeration..."
OUTPUT=$(su -c "chroot /data/local/tmp/chrootDebian /usr/bin/env VK_ICD_FILENAMES=$ICD_PATH TU_DEBUG=kgsl /usr/bin/vulkaninfo --summary 2>&1")

if echo "$OUTPUT" | grep -q "I can't KHR_display"; then
    echo -e "  [${C_ORANGE}!${NC}] ${C_BOLD}VK_KHR_display Bug Detected${NC}"
    echo -e "      Status: vkEnumeratePhysicalDevices fails due to Display Initialization."
    echo -e "      Reason: Kernel 4.14 MSM DRM mismatch (requires >= 1.6, found 1.2.0)."
    echo -e "      Impact: Apps requesting Display Surfaces (headless/VR) will crash."
    echo -e "      Workaround: Use X11/Wayland surface apps only."
else
    if echo "$OUTPUT" | grep -q "Adreno (TM) 640"; then
        echo -e "  [${C_GREEN}✓${NC}] Vulkan HW Acceleration: ACTIVE (Adreno 640)"
    else
        echo -e "  [${C_RED}✗${NC}] Vulkan HW Acceleration: INACTIVE (Fallback to LLVMPIPE)"
    fi
fi

# 4. Check OpenGL / Zink
echo -e "\n${C_BOLD}${C_CYAN}[OpenGL Check]${NC} Testing Zink + Turnip Pipeline..."
GL_INFO=$(su -c "chroot /data/local/tmp/chrootDebian /usr/bin/env DISPLAY=:0 GALLIUM_DRIVER=zink MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=kgsl glxinfo -B 2>/dev/null | grep -E 'renderer string|OpenGL version string'")

if [ -n "$GL_INFO" ]; then
    echo -e "$GL_INFO" | sed 's/^/  /'
else
    echo -e "  [${C_RED}✗${NC}] glxinfo failed. (Is X11 running?)"
fi

echo -e "\n${C_BOLD}${C_CYAN}[Summary]${NC} Diagnostic Complete."
