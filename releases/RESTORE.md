# Debian Chroot — GPU Drivers & Modifications Bundle

This bundle preserves the **non-reinstallable** parts of the Debian 12 workstation
chroot that live at `/data/local/tmp/chrootDebian`:

- **Turnip + Zink GPU drivers** (Mesa with KGSL backend for Adreno 640)
- **Our modifications**: session launcher, hardware-accel profile, `fix_mmap.so` (close_range syscall fix), battery monitor, `vk_test` GPU smoke-test, and all host-side dashboard scripts
- **`packages.manifest`**: a `dpkg --get-selections` list so the full package set can be reinstalled with one `apt` command

The full Debian base is **not** included — you download a fresh Debian rootfs and
apply this bundle on top (see *Restore Procedure*).

> **Credentials (chroot)**
> - User: `ruusian` (UID 1000, in `sudo,audio,video,input,render,disk,plugdev`)
> - `ruusian` sudo password: **`1234`**
> - `root` has no password set; use `sudo -i` from `ruusian` or the host `su -c` bridge.

> **Privacy**: this bundle contains **no** personal files or secrets. The chroot's
> `.hermes/` (AI config, `.env`, `auth.json`), `.ssh`, `.gnupg`, `.git-credentials`,
> browser profiles, and `Documents/Downloads/...` were intentionally excluded.

---

## Contents

```
gpu-drivers/
  usr/lib/aarch64-linux-gnu/libvulkan_freedreno.so   # Turnip Vulkan driver (KGSL)
  usr/lib/aarch64-linux-gnu/dri/zink_dri.so          # Zink OpenGL-on-Vulkan
  usr/share/vulkan/icd.d/freedreno_icd.aarch64.json  # Vulkan ICD
  etc/profile.d/99-hardware-acceleration.sh          # GPU env profile (Turnip+Zink + LD_PRELOAD fix)
mods/
  usr/local/bin/user-session.sh                       # XFCE session initializer
  usr/local/bin/v2-launch.sh                          # chroot entrypoint
  usr/local/bin/battery-monitor.sh                    # genmon battery plugin
  usr/local/bin/vk_test                               # GPU smoke-test binary
  home/ruusian/fix_mmap.so + .c                       # close_range LD_PRELOAD fix
  *.sh                                                # host dashboard scripts (cmds.sh, etc.)
packages.manifest                                     # dpkg --get-selections
restore.sh                                            # automated installer (below)
```

---

## Restore Procedure

Run from the Termux host. `$CHROOT` is the mounted chroot path
(`/data/local/tmp/chrootDebian`).

### 1. Obtain a fresh Debian rootfs (aarch64, bookworm)

```bash
# Example using debootstrap on a Linux box, or download a prebuilt tarball:
debootstrap --arch=arm64 --variant=minbase bookworm "$CHROOT" http://deb.debian.org/debian
```

Then mount the chroot (bind `/dev /proc /sys /tmp /sdcard ...`) — use the repo's
`scripts/mount-debian.sh` which also remounts `/data` with `suid` so `sudo`/`su` work.

### 2. Apply this bundle

```bash
tar -xzf gpu-modifications-bundle.tar.gz -C /
# or, inside an already-mounted chroot:
#   tar -xzf gpu-modifications-bundle.tar.gz -C "$CHROOT"
bash mods/restore.sh "$CHROOT"
```

`restore.sh` does:
- Copies GPU drivers into the chroot's `/usr/...`
- Installs `user-session.sh`, `v2-launch.sh`, `battery-monitor.sh`, `vk_test` into `/usr/local/bin`
- Drops `99-hardware-acceleration.sh` into `/etc/profile.d` (sets Turnip+Zink env **and** `LD_PRELOAD=/home/ruusian/fix_mmap.so`)
- Installs `fix_mmap.so`/`.c` into `/home/ruusian`
- Creates the `ruusian` user (UID 1000) with sudo + the `1234` password
- Runs `apt-get update`, then replays `packages.manifest` via `dpkg --set-selections` + `apt-get dselect-upgrade`

### 3. Finish

```bash
bash ~/cmds.sh        # dashboard -> [1] Start GUI
```

---

## GPU verification (inside chroot, as ruusian)

```bash
export MESA_LOADER_DRIVER_OVERRIDE=zink
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
glxinfo | grep "OpenGL renderer"   # expect: zink (Turnip Adreno (TM) 640)
/usr/local/bin/vk_test              # Vulkan smoke test
```

If `glxinfo`/Vulkan can't see the GPU, confirm `/dev/kgsl-3d0` exists and that
`ruusian` is in the `video`/`render` groups (`id ruusian`). If apps crash with a
`close_range` error, confirm `LD_PRELOAD=/home/ruusian/fix_mmap.so` is set (it is
exported by `99-hardware-acceleration.sh`).
