# --- SUPER-LEVEL OS HARDWARE BRIDGE (v15.4) ---

# 1. CORE GPU PIPELINE - llvmpipe fallback (Zink/Vulkan broken on older kernels)
# Vulkan via Turnip fails on kernel 4.14+MSM DRM (known KHR_display bug).
# Use llvmpipe for reliable software OpenGL rendering.
export GALLIUM_DRIVER=llvmpipe
unset MESA_LOADER_DRIVER_OVERRIDE
unset TU_DEBUG
unset VK_ICD_FILENAMES

# 2. RUNTIME & IPC
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000
export PULSE_SERVER=tcp:127.0.0.1:4713

# 3. FIXES
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
