# --- GPU CONFIG (v2.0) ---
# Adreno 640 (Snapdragon 855) with hardware Turnip Vulkan via KGSL
# Custom Mesa 26.0.8 built with -Dfreedreno-kmds=kgsl from source
# /dev/kgsl-3d0 accessed directly -- no DRM dependency
# GL still uses system llvmpipe (GL 4.5)

export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000

# 1. Vulkan via Turnip KGSL (hardware Adreno Vulkan)
export VK_ICD_FILENAMES=/etc/vulkan/icd.d/freedreno_icd.aarch64.json
export VK_LOADER_DRIVERS_DISABLE=/usr/share/vulkan/icd.d/lvp_icd.json

# 2. Firefox -- WebRender uses Vulkan; no RDD sandbox inside chroot
export MOZ_ENABLE_WAYLAND=0
export MOZ_DISABLE_RDD_SANDBOX=1

# 3. Mesa tuning for WebGL/GL compatibility
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
export MESA_EXTENSION_OVERRIDE="+GL_EXT_texture_compression_s3tc"
