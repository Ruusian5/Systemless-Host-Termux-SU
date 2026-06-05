# GPU Stack

> **Generated:** 2026-06-01  
> **Device:** LG G8X (LM-G850) — Snapdragon 855  
> **GPU:** Adreno 640  
> **Kernel:** 4.14.355

---

## 1. Hardware

| Property | Value |
|----------|-------|
| SoC | Qualcomm Snapdragon 855 (SM8150) |
| GPU | Adreno 640 |
| Frequency | ~585 MHz |
| Kernel driver | KGSL (Qualcomm Kernel Graphics Subsystem) |
| Device node | `/dev/kgsl-3d0` (mode 0666 after mount-debian.sh) |
| DRI nodes | `/dev/dri/card0` (226:0), `/dev/dri/renderD128` (226:128) — mode 0666 |
| Dedicated VRAM | None (UMA — shared with system RAM) |

---

## 2. Software Stack Architecture

### 2.1 Primary Graphics Path (OpenGL via Zink over Turnip)

```
┌──────────────────────────────────────────────────────────┐
│  APPLICATION (XFCE, Firefox, glxgears, etc.)              │
│  └─ OpenGL / GLX calls via libGL.so                       │
│                                                           │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  DEBIAN CHROOT (guest)                                │ │
│  │                                                        │ │
│  │  Mesa Gallium Framework                                │ │
│  │  ├─ Zink State Tracker (GALLIUM_DRIVER=zink)           │ │
│  │  │  Translates OpenGL → Vulkan                        │ │
│  │  │                                                     │ │
│  │  ├─ Turnip Vulkan Driver (freedreno)                   │ │
│  │  │  Translates Vulkan → KGSL commands                  │ │
│  │  │  ICD: /usr/share/vulkan/icd.d/freedreno_icd.aarch64.json │
│  │  │  Lib: /usr/lib/aarch64-linux-gnu/libvulkan_freedreno.so  │
│  │  │  API Version: 1.4.350                               │ │
│  │  │  Config: TU_DEBUG=kgsl,noconform                    │ │
│  │  │                                                     │ │
│  │  └─ Gallium WSI (Window System Integration)            │ │
│  │     → X11 shared memory (DRI3/Present extension)       │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                           │
│  ════════════════ Bind mount bridge ════════════════      │
│                                                           │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  TERMUX HOST                                          │ │
│  │                                                        │ │
│  │  /dev/kgsl-3d0 ← (bind-mounted to chroot)              │ │
│  │  /dev/dri/* ← (bind-mounted to chroot)                 │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  ANDROID KERNEL                                       │ │
│  │                                                        │ │
│  │  KGSL Driver (msm_kgsl.ko)                             │ │
│  │  ├─ GPU command submission                             │ │
│  │  ├─ Memory management (IOMMU)                          │ │
│  │  └─ Power management (frequency scaling)               │ │
│  │                                                        │ │
│  │  DRM Driver (msm_drm.ko)                               │ │
│  │  └─ Display controller, KMS (Kernel Mode Setting)      │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                           │
│  QUALCOMM ADRENO 640 (Hardware)                           │
└──────────────────────────────────────────────────────────┘
```

### 2.2 Fallback Path (VirGL)

```
Application → VirGL Gallium Driver → Unix Socket →
Termux Host virgl_test_server_android → Host Mesa (Freedreno) → KGSL
```

VirGL is **not currently active** but the `virgl_test_server_android` binary is installed on the host and the socket `.virgl_test` exists.

### 2.3 Software Fallback (llvmpipe)

If both Zink and VirGL fail, Mesa defaults to software rendering via llvmpipe. This is very slow (software rasterization on CPU) and is blocked by `LIBGL_ALWAYS_SOFTWARE=0`.

---

## 3. Vulkan Details

### 3.1 Available ICDs (inside chroot)

From `/usr/share/vulkan/icd.d/`:

| ICD | Driver | Architecture | Active |
|-----|--------|-------------|--------|
| `freedreno_icd.aarch64.json` | Turnip KGSL | aarch64 | **YES** |
| `freedreno_icd.json` | Turnip (generic) | multi-arch | No |
| `freedreno_host.json` | Turnip (host) | unknown | No |
| `broadcom_icd.json` | Broadcom VideoCore | arm64 | No |
| `panfrost_icd.json` | Panfrost (Mali) | arm64 | No |
| `radeon_icd.json` | RADV (AMD) | arm64 | No |
| `virtio_icd.json` | VirtIO-GPU | arm64 | No |
| `gfxstream_vk_icd.json` | GFXStream (emulation) | arm64 | No |
| `lvp_icd.json` | LLVMpipe (software) | arm64 | No |

### 3.2 Turnip Configuration

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `TU_DEBUG=kgsl` | Enables KGSL backend | Uses Qualcomm's proprietary kernel interface |
| `TU_DEBUG=noconform` | Disables Vulkan conformance | Allows running on non-standard KGSL path |
| `VK_ICD_FILENAMES` | Points to freedreno_icd.aarch64.json | Selects the aarch64 Turnip ICD |

### 3.3 Vulkan API Support (via Turnip)

| Feature | Status |
|---------|--------|
| Vulkan API Version | 1.4.350 (driver) / 1.3 (hardware limit) |
| VK_KHR_display | **Known bug** — causes enumeration error with KGSL |
| VK_KHR_xcb_surface | Supported |
| VK_KHR_xlib_surface | Supported |
| Pipeline Cache | Supported |
| Descriptor Indexing | Supported (partially) |

---

## 4. OpenGL Details

### 4.1 Configuration

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `GALLIUM_DRIVER=zink` | Force Zink state tracker | Translates GL → Vulkan |
| `MESA_LOADER_DRIVER_OVERRIDE=zink` | Force Mesa driver load | Ensures Mesa loads Zink |
| `MESA_GL_VERSION_OVERRIDE=4.6` | Advertise GL 4.6 | Enables modern GL features |
| `MESA_GLSL_VERSION_OVERRIDE=460` | Advertise GLSL 460 | Enables modern shaders |
| `MESA_EXTENSION_OVERRIDE` | Enable S3TC | Texture compression support |

### 4.2 Actual Renderer

- **Renderer:** Zink (OpenGL over Vulkan)
- **Vulkan driver:** Turnip (Freedreno)
- **Kernel interface:** KGSL
- **Expected OpenGL version:** 4.6 (compatibility profile)
- **Confirmed by:** `glxinfo -B` output (observed during GPU diagnostic)

### 4.3 GLX Information

| Component | Detail |
|-----------|--------|
| GLX Version | 1.4 |
| GLX Extensions | GLX_ARB_create_context, GLX_EXT_swap_control, etc. |
| Direct Rendering | Yes (DRI3) |
| EGL | Available via `libEGL_mesa.so` |

---

## 5. VirGL Bridge Details

### 5.1 Host Side

| Component | Location |
|-----------|----------|
| Binary | `virgl_test_server_android` (from Termux package `virglrenderer-android`) |
| Version | 1.3.0 |
| Socket | `/data/data/com.termux/files/usr/tmp/.virgl_test` |
| Launch | `virgl_test_server_android --multi-clients &` |

### 5.2 Guest Side

VirGL gallium driver (`/usr/lib/aarch64-linux-gnu/dri/virgl_dri.so`) is **not present** in the chroot. The VirGL fallback path is not functional without installing the driver inside Debian.

---

## 6. Device Node Permissions

### 6.1 After `mount-debian.sh`

| Node | Host | Chroot (bind mount) |
|------|------|---------------------|
| `/dev/kgsl-3d0` | mode 0666, root:root | mode 0666, root:root |
| `/dev/dri/card0` | mode 0666, root:graphics | mode 0666, root:graphics |
| `/dev/dri/renderD128` | mode 0666, root:graphics | mode 0666, root:graphics |

### 6.2 Permissions Logic

The `mount-debian.sh` script sets 0666 on all GPU nodes to ensure the chroot user `ruusian` (UID 1000) can access them. This is a security tradeoff — any process inside the chroot can access the GPU directly.

---

## 7. Firefox GPU Configuration

Firefox uses WebRender with Vulkan backend via Turnip:

```
MOZ_X11_EGL=1
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
```

Sandboxes are disabled (MOZ_DISABLE_*_SANDBOX=1) because `unshare()` syscall is blocked inside the chroot.

Firefox detects **no GPU** via PCI (no PCI bus in chroot), but still renders via Vulkan/EGL.

---

## 8. Performance Characteristics

| Operation | Expected Performance | Notes |
|-----------|---------------------|-------|
| XFCE Desktop (compositing off) | Smooth | 2D only |
| Video playback (VAAPI) | Not accelerated | No VAAPI driver for KGSL |
| Firefox WebRender | Moderate | Vulkan overhead from Zink translation |
| GL applications | Moderate | Double translation (GL → Vulkan → KGSL) |
| Vulkan-native applications | Good | Direct path via Turnip |
| 3D gaming | Limited | Driver maturity + translation overhead |

---

## 9. Known GPU Issues

| Issue | Root Cause | Workaround |
|-------|-----------|------------|
| XFCE black screen | XFWM4 compositing conflicts with Zink | `xfconf-query -c xfwm4 -p /general/use_compositing -s false` |
| VK_KHR_display error | KGSL doesn't support display enumeration | Ignore (non-fatal) |
| No PCI GPU detection | Chroot has no `/sys/bus/pci` | Firefox error is cosmetic only |
| Firefox "libEGL no display" | D-Bus / X socket timing | Retry launching Firefox |
| Software rendering fallback | Missing /dev/dri/ bind mount | Run `bash ~/mount-debian.sh` |
| Some Vulkan 1.3 features missing | Turnip KGSL driver maturity | Expected on Adreno 640 |
