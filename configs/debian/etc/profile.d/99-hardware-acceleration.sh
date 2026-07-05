# --- HARDWARE ACCELERATION CONFIG ---
# VirGL HW acceleration confirmed working with Debian Mesa 22.3.6+
# virgl_test_server_android runs on Termux host → Adreno 640 via EGL
# Chroot connects via GALLIUM_DRIVER=virpipe (virgl Gallium pipe)
# Tested: glmark2 → GL_RENDERER: virgl (Adreno (TM) 640)

# Default GPU: virgl (HW acceleration) — virgl server started by dashboard
export GALLIUM_DRIVER=virpipe
export MESA_GL_VERSION_OVERRIDE=4.0
unset MESA_LOADER_DRIVER_OVERRIDE
unset LIBGL_ALWAYS_SOFTWARE

export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000
export PULSE_SERVER=tcp:127.0.0.1:4713
