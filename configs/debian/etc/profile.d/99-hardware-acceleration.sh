# --- HARDWARE ACCELERATION CONFIG ---
# Kernel 4.14.357: KGSL available but Turnip/MSM need 5.x+
# VirGL vtest driver not available in Debian Mesa (needs -Dgallium-virpipe)
# Using llvmpipe software renderer (only reliable option)

export GALLIUM_DRIVER=llvmpipe
unset MESA_LOADER_DRIVER_OVERRIDE
unset TU_DEBUG

export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000
export PULSE_SERVER=tcp:127.0.0.1:4713

export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
