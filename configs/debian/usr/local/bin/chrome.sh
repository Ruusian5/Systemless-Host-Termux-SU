#!/bin/bash
# --- HIGH-PERFORMANCE CHROMIUM LAUNCHER (ZINK) ---
export DISPLAY=:0
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json

# Optimized flags for 4K video and raw GPU rendering
CHROME_BIN="/home/Ruusian5/.local/opt/chromium/usr/lib/chromium/chromium"
FLAGS="--ignore-gpu-blocklist --enable-gpu-rasterization --enable-zero-copy --ozone-platform=x11 --use-gl=egl --enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization --disable-software-rasterizer --num-raster-threads=4"

exec "$CHROME_BIN" $FLAGS "$@"
