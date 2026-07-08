# --- HARDWARE ACCELERATION CONFIG ---
# Turnip (Vulkan) + Zink (OpenGL-on-Vulkan) for Adreno 640
# VirGL is broken on this device — use native Turnip+Zink instead

# Zink provides OpenGL via Vulkan (Turnip)
export MESA_LOADER_DRIVER_OVERRIDE=zink
export MESA_GL_VERSION_OVERRIDE=4.6
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
unset LIBGL_ALWAYS_SOFTWARE
unset GALLIUM_DRIVER

# close_range syscall is broken on this kernel — must preload the fix
export LD_PRELOAD=/home/ruusian/fix_mmap.so

export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000
export PULSE_SERVER=tcp:127.0.0.1:4713
