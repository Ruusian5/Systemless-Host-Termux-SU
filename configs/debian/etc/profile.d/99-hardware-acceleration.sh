# --- FINAL OPTIMIZED HARDWARE BRIDGE ---

# 1. CORE GRAPHICS
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform,kgsl
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json

# 2. RUNTIME
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000
export PULSE_SERVER=tcp:127.0.0.1:4713

# 3. PERFORMANCE TUNING (SAFER VERSIONS)
export vblank_mode=0
export MESA_GL_VERSION_OVERRIDE=4.3
export MESA_GLSL_VERSION_OVERRIDE=430
export ZINK_DESCRIPTORS=lazy
export MESA_GLTHREAD=true

# 4. SHADER FIXES
# export MESA_EXTENSION_OVERRIDE="GL_EXT_shader_texture_lod GL_EXT_texture_query_lod GL_EXT_texture_filter_anisotropic"

# 5. FIREFOX STABILITY
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_ENABLE_WAYLAND=0
export MOZ_X11_EGL=1
export MOZ_ACCELERATED_VIDEO=1
export MOZ_WEBRENDER=1

# 6. AUDIO SYNC
export PULSE_LATENCY_MSEC=60
