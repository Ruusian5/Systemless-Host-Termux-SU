# --- SUPER-LEVEL OS HARDWARE BRIDGE (v15.4) ---

# 1. CORE GPU PIPELINE (ZINK + TURNIP KGSL)
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform,kgsl
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json

# 2. RUNTIME & IPC
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1001
export PULSE_SERVER=tcp:127.0.0.1:4713

# 3. FIXES
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
