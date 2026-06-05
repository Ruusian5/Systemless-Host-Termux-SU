# User Model

> **Generated:** 2026-06-01  
> **Device:** LG G8X (LM-G850) — Android 14

---

## 1. User Layer Overview

```
┌──────────────────────────────────────────────────────────┐
│  ANDROID SYSTEM                                           │
│  ├─ root (uid 0) — kernel, Magisk                        │
│  └─ u0_a569 (uid 10569) — Termux app user                │
│                                                           │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  TERMUX (host)                                        │ │
│  │  └─ u0_a569 (uid 10569) — shell, all processes        │ │
│  │                                                       │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  su → temporary root (uid 0)                      │ │ │
│  │  │  Used for: mount, chroot, governor control        │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  DEBIAN CHROOT (guest)                                │ │
│  │  ├─ root (uid 0) — daemons (dbus, mounts)             │ │
│  │  └─ ruusian (uid 1000, gid 1000) — desktop, apps     │ │
│  └──────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

---

## 2. Android Users

### 2.1 System Users (Relevant)

| Username | UID | Context | Role |
|----------|-----|---------|------|
| `root` | 0 | `u:r:su:s0` | Kernel, Magisk, privileged operations |
| `system` | 1000 | `u:r:system_app:s0` | Android system server |
| `u0_a569` | 10569 | `u:r:untrusted_app_27:s0` | Termux application |

### 2.2 Termux User: `u0_a569`

| Attribute | Value |
|-----------|-------|
| UID | 10569 |
| GID | 10569 |
| Groups | `10569(u0_a569)`, `1077(external_storage)`, `3003(inet)`, `9997(everybody)`, `20569(u0_a569_cache)`, `50569(all_a569)` |
| SELinux context | `u:r:untrusted_app_27:s0:c57,c258,c512,c768` |
| HOME | `/data/data/com.termux/files/home` |
| Shell (interactive) | `/data/data/com.termux/files/usr/bin/bash` (Termux bash) |

**Note:** `u0_a569` is a secondary Android user profile (app-level user, not a real multi-user profile). It has restricted SELinux context `untrusted_app_27` — no direct access to many `/proc` files, system resources, or hardware.

---

## 3. Root (MagiskSU)

| Attribute | Value |
|-----------|-------|
| Mechanism | Magisk 30.7 (MAGISK:R) |
| Binary | `/debug_ramdisk/magisk` |
| Invocation | `su -c "command"` |
| Capabilities | Full root — mount, chroot, kgsl access, governor control |

**Used for:**
- Bind mounting chroot bridges (`mount-debian.sh`)
- Running Debian chroot (`busybox chroot`)
- Setting CPU governors (performance/schedutil/powersave)
- Accessing `/proc/loadavg`, `/proc/stat` (not world-readable on this kernel)
- Modifying Android display resolution (`wm` command)
- Setting SELinux permissive mode (`setenforce 0`)

---

## 4. Debian Chroot Users

### 4.1 `root` (uid 0)

| Attribute | Value |
|-----------|-------|
| UID | 0 |
| GID | 0 |
| HOME | `/root` |
| Shell | `/bin/bash` |
| Password | Set (locked with `!` prefix in shadow) |
| Groups | `root` |
| Sudo access | N/A (already root) |

**Used for:**
- Starting system D-Bus daemon (`dbus-daemon --system`)
- Creating runtime directories
- Running `v2-launch.sh` (session controller)

### 4.2 `ruusian` (uid 1000)

| Attribute | Value |
|-----------|-------|
| UID | 1000 |
| GID | 1000 |
| HOME | `/home/ruusian` |
| Shell | `/bin/bash` |
| Password | Set (debian default) |
| Groups | `root` (via `/etc/group`: `root:x:0:ruusian`) |
| Sudo access | `NOPASSWD: ALL` (sudoers configured for passwordless root) |

**Used for:**
- Running XFCE desktop session (`user-session.sh`)
- Running Firefox, terminal, file manager
- All interactive work

**Note:** `ruusian` has passwordless sudo access. This is a **security risk** — any process running as `ruusian` can trivially escalate to root inside the chroot.

---

## 5. User ID Mapping

### 5.1 Across Layers

| Layer | User | UID | GID | Groups |
|-------|------|-----|-----|--------|
| Android | `root` | 0 | 0 | root |
| Android | `u0_a569` | 10569 | 10569 | external_storage, inet, everybody |
| Termux | `u0_a569` | 10569 | 10569 | (same as Android) |
| Debian | `root` | 0 | 0 | root |
| Debian | `ruusian` | 1000 | 1000 | root |

### 5.2 No Cross-Layer UID Mapping

UIDs are **not shared** across layers:
- `u0_a569` (10569) on host ≠ any user inside Debian
- `ruusian` (1000) inside chroot ≠ any user on host (UID 1000 on Android is `system`)
- File ownership between layers is incompatible

### 5.3 Implications

- Files created inside chroot as `ruusian` have UID 1000
- Files shared via `$TMPDIR` bind mount appear as numeric UID 1000 on the host (no matching user name)
- No NFS/UID mapping exists — all cross-layer file sharing uses bind mounts with permission 0666

---

## 6. Permission Model

### 6.1 Host (Termux) — Restricted

| Resource | Access | Reason |
|----------|--------|--------|
| `/proc/stat` | ❌ Denied | `hidepid=2` mount option |
| `/proc/loadavg` | ❌ Denied | `hidepid=2` mount option |
| `/sys/class/thermal` | ✅ Readable | World-readable |
| `/sys/devices/system/cpu` | ❌ Denied (write) | Root only for governors |
| `/dev/kgsl-3d0` | ❌ Denied | Root-only by default |
| `/dev/dri/*` | ❌ Denied | Root-only by default |
| `/data` | ✅ Readable | F2FS partition |
| /proc/mounts | ✅ Readable | World-readable |

### 6.2 Root (via MagiskSU) — Full Access

| Resource | Access | Method |
|----------|--------|--------|
| All /proc/* | ✅ Full | `su -c cat /proc/stat` |
| All /dev/* | ✅ Full | `su -c chmod 666 /dev/kgsl-3d0` |
| CPU governors | ✅ Full | `su -c "echo performance > ..."` |
| Mount operations | ✅ Full | `su -c mount` |
| Chroot | ✅ Full | `su -c busybox chroot ...` |
| SELinux | ✅ Full | `su -c setenforce 0` |

### 6.3 Guest (Debian Chroot) — Virtual Root

Inside the chroot, the kernel enforces normal Unix permissions. The chroot has its own `/etc/passwd`, `/etc/group`, and file ownership.

| Resource | ruusian | root |
|----------|---------|------|
| Own home | ✅ Full | ✅ Full |
| System files | ❌ Read-only | ✅ Full |
| DRI devices | ✅ chmod 0666 | ✅ Full |
| sudo | ✅ Passwordless | N/A |
| KGSL | ✅ (via bind mount 0666) | ✅ |
| PulseAudio | ✅ (TCP socket) | ✅ |

---

## 7. Key Security Observations

| Risk | Detail | Severity |
|------|--------|----------|
| Passwordless sudo | `ruusian` has `NOPASSWD: ALL` | HIGH |
| 0666 GPU nodes | KGSL + DRI devices world-writable | MEDIUM |
| PulseAudio no auth | `auth-anonymous=1` TCP module | MEDIUM |
| Hardcoded passwords | `install.sh` sets known passwords | MEDIUM |
| No user namespace | All chroot processes share host UID space | LOW |
| SELinux untrusted app | Termux runs as `untrusted_app_27` | LOW (expected) |
