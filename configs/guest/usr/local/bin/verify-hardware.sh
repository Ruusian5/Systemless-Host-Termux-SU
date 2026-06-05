#!/bin/bash
# --- HARDWARE VERIFICATION SCRIPT (INTERNAL) ---
echo "[1] Checking Vulkan Instance..."
export XDG_RUNTIME_DIR=/run/user/1000
vulkaninfo --summary 2>/dev/null | grep -E "Adreno|device" || echo "Vulkan: FAILED (Check SELinux/Permissions)"

echo "[2] Checking OpenGL via Zink..."
export DISPLAY=:0
export MESA_LOADER_DRIVER_OVERRIDE=zink
export GALLIUM_DRIVER=zink
export TU_DEBUG=noconform
glxinfo -B 2>/dev/null | grep -E "renderer|Accelerated" || echo "OpenGL: FAILED (Check X11 Connection)"
