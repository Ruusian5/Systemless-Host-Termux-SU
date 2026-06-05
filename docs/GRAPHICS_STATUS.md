# Graphics Stack Status
**Date:** 2026-06-05  
**GPU:** Adreno 640 (Snapdragon 855)

## 1. Acceleration Overview

| API | Status | Renderer | Version |
|-----|--------|----------|---------|
| **OpenGL** | ✅ Hardware | Zink (via Turnip) | 4.6 (Core) |
| **Vulkan** | ✅ Hardware | Turnip (Mesa 26.0.8) | 1.3.335 |
| **GLES** | ✅ Hardware | Zink (via Turnip) | 3.2 |

---

## 2. Driver Stack

- **Kernel Mode Driver (KMD):** KGSL (Qualcomm Graphics System Layer).
- **Vulkan Driver:** Mesa Turnip (`freedreno`) built with KGSL support.
- **OpenGL Driver:** Mesa Zink (OpenGL over Vulkan).
- **Mesa Version:** 26.0.8 (Custom Build).

---

## 3. Configuration (99-hardware-acceleration.sh)

```bash
export VK_ICD_FILENAMES=/etc/vulkan/icd.d/freedreno_icd.aarch64.json
export VK_LOADER_DRIVERS_DISABLE=/usr/share/vulkan/icd.d/lvp_icd.json
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
```

---

## 4. Performance Tuning

- **Zink:** Provides full OpenGL 4.6 support on hardware that natively only supports GLES.
- **Turnip:** Highly optimized Vulkan driver for Adreno 6xx.
- **Compositing:** Currently **DISABLED** in XFWM4 to avoid "Black Screen" issues common with Zink + Termux:X11 buffer swapping.

---

## 5. Verification Commands

```bash
glxinfo -B | grep "Accelerated"
vulkaninfo --summary
```

---
**Status:** Graphics Stack Validation Complete. Moving to Phase 5 (Audio System).
