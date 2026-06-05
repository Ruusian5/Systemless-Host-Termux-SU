# --- PRO WORKSTATION GPU HOOKS (v0.2) ---
# OPTIMIZED FOR ADRENO 640 (SNAPDRAGON 855)
# BY RUUSIAN

export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000

# 1. Vulkan via Turnip (KGSL path for native GPU acceleration)
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
export TU_DEBUG=kgsl,noconform

# 2. Firefox WebRender uses Vulkan directly — no Zink/EGL overrides needed.
# Removing GALLIUM_DRIVER=zink & MOZ_X11_EGL=1 because EGL fails to init in chroot;
# Firefox falls back to CPU for WebGL/canvas, while WebRender still uses Vulkan
# via VK_KHR_xcb_surface (which Turnip supports).
export MOZ_ENABLE_WAYLAND=0
export MOZ_DISABLE_RDD_SANDBOX=1

# 3. Mesa tuning for WebGL compatibility
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
export MESA_EXTENSION_OVERRIDE="+GL_EXT_texture_compression_s3tc"
