# --- UNIVERSAL HARDWARE DRIVER BRIDGE ---
# This script ensures every app (Firefox, Chromium, etc.) automatically detects the GPU.

# 1. CORE GRAPHICS BRIDGE
export MESA_LOADER_DRIVER_OVERRIDE=zink
export GALLIUM_DRIVER=zink
export TU_DEBUG=noconform
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json

# 2. VIDEO DECODING BRIDGE (VA-API / VDPAU)
export LIBVA_DRIVER_NAME=zink
export VDPAU_DRIVER=zink

# 3. PERFORMANCE TUNING
export vblank_mode=0
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
export ZINK_DESCRIPTORS=lazy

# 4. BROWSER SPECIFIC (FF/Chromium)
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_ENABLE_WAYLAND=0
