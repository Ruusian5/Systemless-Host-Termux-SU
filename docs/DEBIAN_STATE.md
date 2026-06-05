# Debian Chroot Environment — State Audit

> **Generated:** 2026-06-01  
> **Chroot Root:** `/data/local/tmp/chrootDebian`  
> **Host Device:** LG LM-G850 (LGE) — Android 14 (API 34)

---

## 1. Chroot Access

### Entry Method

```bash
su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /bin/sh"
```

**Important:** The default busybox `sh` shell inside the chroot does **not** have `PATH` set. Always export it first:

```bash
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
```

**Note:** `/dev/null` is not accessible inside the chroot — redirects to it will fail with "Permission denied".

---

## 2. OS / Kernel

| Field       | Value                                        |
|-------------|----------------------------------------------|
| OS          | Debian GNU/Linux forky/sid (testing/unstable)|
| Kernel      | 4.14.355 #1 SMP PREEMPT                      |
| Architecture| aarch64                                      |
| Host Kernel | Linux 4.14.355 Thu Oct 2 20:47:57 +07 2025   |
| Chroot Size | ~130 MB (root directory, excluding mounts)   |

### `/etc/debian_version`

```
bookworm/sid
```

### `/etc/os-release` (partial)

```
PRETTY_NAME="Debian GNU/Linux forky/sid"
VERSION_CODENAME=forky
ID=debian
VERSION_ID="13"
```

---

## 3. Filesystem Structure

### Root Directory Listing

```
total 693
drwxr-xr-x. 18 root root   3452 Jun  1 15:15 .
drwxr-xr-x. 18 root root   3452 Jun  1 15:15 ..
lrwxrwxrwx.  1 root root      7 May 17 18:00 bin -> usr/bin
drwxr-xr-x.  4 root root   3452 Jun  1 15:14 boot
drwxr-xr-x.  2 root root   3452 May 19 21:04 dev
drwxr-xr-x. 94 root root   8192 Jun  1 14:32 etc
drwxr-xr-x.  3 root root   3452 May 19 21:04 home
lrwxrwxrwx.  1 root root      7 May 17 18:00 lib -> usr/lib
lrwxrwxrwx.  1 root root      9 May 17 18:00 lib64 -> usr/lib64
drwx------.  2 root root  16384 May 17 18:32 lost+found
drwxr-xr-x.  2 root root   3452 Jun  1 15:07 media
drwxr-xr-x.  2 root root   3452 May 31 12:38 mnt
drwxr-xr-x.  2 root root   3452 Jun  1 15:15 opt
drwxr-xr-x.  2 root root   3452 May 12  2024 proc
drwx------.  5 root root   3452 May 31 13:09 root
drwxr-xr-x.  3 root root   3452 Jun  1 14:28 run
lrwxrwxrwx.  1 root root      8 May 17 18:00 sbin -> usr/sbin
drwxr-xr-x.  2 root root   3452 Jun  1 15:15 snap
drwxr-xr-x.  2 root root   3452 Jun  1 15:07 srv
drwxr-xr-x.  2 root root   3452 May 31 15:08 sys
drwxrwxrwt. 10 root root   3452 Jun  1 15:15 tmp
drwxr-xr-x. 10 root root   3452 May 17 18:00 usr
drwxr-xr-x. 12 root root   3452 May 19 21:04 var
-rw-r--r--.  1 root root 139386880 May 31 13:35 debian12-arm64.tar.gz
```

### Key Symlinks

| Symlink   | Target        |
|-----------|---------------|
| `/bin`    | `usr/bin`     |
| `/lib`    | `usr/lib`     |
| `/lib64`  | `usr/lib64`   |
| `/sbin`   | `usr/sbin`    |

### Sparse / Empty Mount Points

- `/proc/`, `/sys/`, `/dev/` — empty (minimal dev, no procfs/sysfs)
- `/mnt/`, `/media/` — empty
- `/srv/`, `/opt/`, `/snap/` — empty
- `df -h` fails: "cannot read table of mounted file systems"
- `/mnt/` and `/media/` are empty (no external/Android mounts)

### `/dev` Contents

- Minimal set of device nodes
- No `/dev/dri/` inside the chroot (GPU nodes exposed from host via bind mount)

---

## 4. Users & Groups

### Users (`/etc/passwd`)

| Username  | UID  | GID  | Home             | Shell         |
|-----------|------|------|------------------|---------------|
| root      | 0    | 0    | /root            | /bin/bash     |
| ruusian   | 1000 | 1000 | /home/ruusian    | /bin/bash     |

### `/etc/group`

- `root:x:0:ruusian` — ruusian can sudo to root  
- Plus standard Debian groups (daemon, bin, adm, etc.)

### `/etc/shadow`

- `root` password hash present (locked: `!` prefix likely)
- `ruusian` password hash present

### Root Home (`/root/`)

- Contains `test_sudo.c` — minimal test binary to check UID/EUID:

```c
#include <stdio.h>
#include <unistd.h>
int main() {
    printf("Real UID: %d\n", getuid());
    printf("Effective UID: %d\n", geteuid());
    return 0;
}
```

---

## 5. User: ruusian

### Home Directory (`/home/ruusian/`)

**20 subdirectories, 15 files** — standard XDG layout with XFCE, Firefox, and development configs.

| Path                    | Description                        |
|-------------------------|------------------------------------|
| `.bashrc`               | Shell config with aliases          |
| `.profile`              | POSIX profile sourcing `.bashrc`   |
| `.bash_logout`          | Logout cleanup                     |
| `.bash_history`         | Bash history                       |
| `.ssh/`                 | SSH keys (ed25519 key pair)        |
| `.mozilla/`             | Firefox/ESR profiles               |
| `.config/`              | XDG config (xfce4, pulse, gtk3)    |
| `.cache/`               | Application cache                  |
| `.local/`               | Local binaries, share data         |
| `.opencode/`            | OpenCode CLI config                |
| `.npm/`                 | npm cache                          |
| `Desktop/`              | Contains `firefox-esr.desktop`     |
| `Documents/`            | (empty)                            |
| `Downloads/`            | (empty)                            |
| `Music/`                | (empty)                            |
| `Pictures/`             | (empty)                            |
| `Public/`               | (empty)                            |
| `Templates/`            | (empty)                            |
| `Videos/`               | (empty)                            |
| `.X11-unix/`            | X11 socket directory in chroot     |
| `fix_mmap.c`            | mmap fix source                    |
| `fix_mmap.so`           | Compiled mmap fix (69816 bytes)    |
| Debug logs              | `firefox_*.log`, `session_debug.log`, `gui-debug.log`, `xfce_audit*.log`, `vlc_*.log` |

### `.bashrc`

```bash
# Debian .bashrc for ruusian
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1:4713
export XDG_RUNTIME_DIR=/run/user/1000

# Aliases
alias set-res="/usr/local/bin/set-res"
alias poweroff="/usr/local/bin/shutdown-system"
alias shutdown="/usr/local/bin/shutdown-system"

# API availability check
if command -v termux-battery-status >/dev/null; then
    echo -e "\e[1;32m[✓] Termux:API Bridge Active\e[0m"
fi

PS1="\e[1;36mruusian@workstation\e[0m:\e[1;34m\w\e[0m$ "

# opencode
export PATH=/home/ruusian/.opencode/bin:$PATH

# Firefox WebRender via Turnip Vulkan
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
export MOZ_X11_EGL=1
```

### SSH Keys

```
-rw-------.  1 ruusian ruusian  411 May 31 13:19 id_ed25519
-rw-r--r--.  1 ruusian ruusian   99 May 31 13:19 id_ed25519.pub
-rw-------.  1 ruusian ruusian  978 May 31 13:19 known_hosts
-rw-r--r--.  1 ruusian ruusian  142 May 31 13:19 known_hosts.old
```

### `.config/` Layout

| Directory       | Description                  |
|-----------------|------------------------------|
| `xfce4/`        | XFCE panel, session, desktop |
| `pulse/`        | PulseAudio client config     |
| `gtk-3.0/`      | GTK3 theme/settings          |
| `autostart/`    | Autostart entries            |
| `dconf/`        | DConf profile/settings       |
| `opencode/`     | OpenCode config              |
| `Thunar/`       | Thunar file manager settings |
| `vlc/`          | VLC media player config      |
| `xscreensaver/` | Screensaver config           |
| `systemd/`      | User systemd units           |
| `procps/`       | procps settings              |
| `uv/`           | Python UV package manager    |
| `fish/`         | Fish shell config (partial)  |
| `ibus/`         | IBus input method config     |
| `htop/`         | Htop config                  |
| `user-dirs.dirs`| XDG user directories         |
| `user-dirs.locale`| XDG locale setting         |

### `.mozilla/` Layout

```
extensions/
firefox/     (default profile)
firefox-esr/ (ESR profile)
```

---

## 6. Package Management

### APT Sources

**`/etc/apt/sources.list`:**
```
deb http://deb.debian.org/debian bookworm main
```

**`/etc/apt/sources.list.d/backports.list`:**
```
deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
```

**`/etc/apt/sources.list.d/sid.list`:**
```
deb http://deb.debian.org/debian sid main
```

**`/etc/apt/sources.list.d/nodesource.sources.bak`:**
```
Types: deb
URIs: https://deb.nodesource.com/node_20.x
Suites: nodistro
Components: main
Architectures: arm64
Signed-By: /usr/share/keyrings/nodesource.gpg
```

**Note:** Primary source is `bookworm` (stable). Additional sources pull from `sid` (unstable) and `bookworm-backports`. NodeSource provides Node.js 20 for arm64.

### Installed Packages (`dpkg -l`)

Full output collected — spans all packages installed via apt. Key packages identified:

| Category               | Notable Packages                    |
|------------------------|-------------------------------------|
| Desktop Environment    | xfce4, xfce4-goodies, lightdm       |
| Display Server         | xserver-xorg-core, xserver-xorg     |
| GPU / Mesa             | mesa, mesa-utils, libegl-mesa0, libgles2-mesa |
| Vulkan                 | mesa-vulkan-drivers, libvulkan1     |
| Audio                  | pulseaudio, pulseaudio-utils        |
| DBus                   | dbus, dbus-x11                      |
| Browser                | firefox, firefox-esr                |
| Development            | gcc, g++, make, python3, nodejs     |
| Shells                 | bash, zsh, fish                     |
| Networking             | openssh-client, openssh-server, curl, wget |
| Editors                | vim, nano                           |
| Utilities              | htop, Thunar, xfce4-terminal        |

---

## 7. Hardware Acceleration

### GPU Device Nodes (Host)

Available on the host at `/dev/dri/` (accessible to chroot via bind mount):

```
crw-rw----. 1 root graphics 226,   0 Jun  1 15:10 card0
crw-rw----. 1 root graphics 226, 128 Jun  1 15:10 renderD128
```

**Mesa DRI drivers** found at `/usr/lib/aarch64-linux-gnu/dri/`:
- kms_swrast_dri.so
- kms_swrast_dri.so
- (and other Mesa DRI drivers)

**No `libvirgl*.so*`** files found in the chroot.

**No `/dev/dri/` inside the chroot** — GPU nodes must be bind-mounted from the host.

### Profile: `/etc/profile.d/99-hardware-acceleration.sh`

```bash
# --- PRO WORKSTATION GPU HOOKS (v0.1.1) ---
# OPTIMIZED FOR ADRENO 640 (SNAPDRAGON 855)
# BY RUUSIAN - MAINTAINER EDITION

export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000

# 1. Primary Hardware Acceleration (Native KGSL Path)
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
export TU_DEBUG=kgsl,noconform
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink

# 2. Strict Hardware Enforcements
export LIBGL_ALWAYS_HW=1
export LIBGL_ALWAYS_SOFTWARE=0

# 3. Performance Tuning
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
export MESA_EXTENSION_OVERRIDE="+GL_EXT_texture_compression_s3tc"
export MOZ_X11_EGL=1
export MOZ_ENABLE_WAYLAND=0
export MOZ_DISABLE_RDD_SANDBOX=1

# 4. VirGL Fallback (Disabled)
# export GALLIUM_DRIVER=virgl
```

### Profile: `/etc/profile.d/drivers.sh`

```bash
export LIBGL_DRIVERS_PATH=/usr/lib/aarch64-linux-gnu/dri
export LD_LIBRARY_PATH=/usr/local/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu:/usr/lib/aarch64-linux-gnu
```

### Profile: `/etc/profile.d/99-workstation-paths.sh`

```bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
```

### Vulkan ICDs available

At `/usr/share/vulkan/icd.d/`:

| ICD File                       | Driver                          |
|--------------------------------|---------------------------------|
| `freedreno_icd.aarch64.json`   | Freedreno/Turnip (Adreno KGSL)  |
| `freedreno_icd.json`           | Freedreno (generic)             |
| `freedreno_host.json`          | Freedreno host variant          |
| `broadcom_icd.json`            | Broadcom VideoCore              |
| `panfrost_icd.json`            | Panfrost (Mali)                 |
| `radeon_icd.json`              | Radeon (RADV)                   |
| `virtio_icd.json`              | VirtIO-GPU                      |
| `gfxstream_vk_icd.json`        | GFXStream (emulation)           |
| `lvp_icd.json`                 | LLVMpipe (software)             |

**Active ICD** (from hardware profile): `freedreno_icd.aarch64.json` → `/usr/lib/aarch64-linux-gnu/libvulkan_freedreno.so` (api_version 1.4.350)

### `glxinfo` / `vulkaninfo`

Neither `glxinfo` nor `vulkaninfo` is installed in the chroot.

---

## 8. Audio (PulseAudio)

### PulseAudio Configuration

- `pulseaudio` and `pulseaudio-utils` installed
- `/etc/pulse/default.pa` — default PulseAudio configuration (not customized)
- `/etc/pulse/client.conf` — exists, standard config
- **Custom SLES source module** at `/etc/pulse/default.pa.d/mic.pa`:
  ```
  load-module module-sles-source
  ```
  This enables Android's SLES audio source for microphone input.

### Connection Model

- `PULSE_SERVER=tcp:127.0.0.1:4713` set in `.bashrc` — connects to PulseAudio running on the **host** (Termux) via TCP
- PulseAudio does **not** run inside the chroot; it runs on the host and is forwarded

---

## 9. Display / Desktop

### XFCE4

- `/usr/share/xfce4/` — populated with XFCE resources
- `/usr/bin/startxfce4` — exists (3304 bytes)
- Session configured to use XFCE via LightDM

### LightDM

- **LightDM installed** but display manager does **not** run inside the chroot
- `/etc/lightdm/lightdm.conf` — standard configuration (everything commented out, defaults apply)
- `/etc/lightdm/lightdm-gtk-greeter.conf` — standard greeter config (all defaults)
- **No `/etc/lightdm/` directory was found** — LightDM config is in standard location

### XFCE Desktop Session Start

The desktop is launched via `/usr/local/bin/user-session.sh` which:
1. Exports DISPLAY=:0
2. Sources the hardware acceleration profile
3. Runs `dbus-launch --sh-syntax` for D-Bus session
4. Launches `startxfce4`

### D-Bus

- `dbus-daemon` binary present
- `/etc/dbus-1/` exists with `system.d/` and `session.d/`
- **D-Bus fails to start** due to `/tmp` permissions — observed in `gui-debug.log`:
  ```
  dbus-daemon[30264]: Failed to start message bus: Failed to bind socket "/tmp/dbus-*": Permission denied
  EOF in dbus-launch reading address from bus daemon
  ```
  This is a known issue with Android's restrictive `/tmp` permissions.

### polkit

- `pkexec` installed at `/usr/bin/pkexec`
- `/etc/polkit-1/` exists

---

## 10. Networking

### Network Configuration

- `/etc/hosts` — contains standard localhost entries
- `/etc/hostname` — set
- `/etc/resolv.conf` — DNS configuration present
- Network is shared with the host kernel (no separate network stack in chroot)

### `/etc/hosts`

```
127.0.0.1 localhost
127.0.1.1 localhost
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

### `/etc/hostname`

```
localhost
```

---

## 11. Custom Scripts (`/usr/local/bin/`)

| Script              | Description                                    |
|---------------------|------------------------------------------------|
| `$cmd`              | Shell shim (unknown purpose)                   |
| `chrome.sh`         | Chrome browser launcher                        |
| `cli-init.sh`       | CLI initialization (shell setup + tmux)        |
| `user-session.sh`   | XFCE desktop session startup with D-Bus        |
| `v2-launch.sh`      | XFCE launch variant 2                          |
| `v3-cli.sh`         | CLI variant 3                                  |
| `verify-hardware.sh`| Hardware acceleration verification             |
| `vlc.sh`            | VLC media player launcher                      |
| `firefox-launcher`  | Firefox wrapper (disables sandboxes, sources HW profile) |

### `firefox-launcher`

```bash
#!/bin/bash
export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1:4713
export XDG_RUNTIME_DIR=/run/user/1000
if [ -f /etc/profile.d/99-hardware-acceleration.sh ]; then
    . /etc/profile.d/99-hardware-acceleration.sh
fi
export MOZ_DISABLE_CONTENT_SANDBOX=1
export MOZ_DISABLE_GMP_SANDBOX=1
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_DISABLE_SOCKET_PROCESS_SANDBOX=1
exec /usr/bin/firefox --new-instance "$@" > /home/ruusian/firefox.log 2>&1
```

All sandboxes are disabled. Firefox runs with WebRender via Turnip Vulkan.

---

## 12. Chroot Environment (inside chroot shell)

```
TERM=linux
PATH=/usr/bin:/bin:/usr/sbin:/sbin
HOME=/root
SHELL=/bin/sh
USER=root
LOGNAME=root
```

Android-specific host environment variables (from `env` inside chroot):

| Variable         | Value                                                      |
|------------------|------------------------------------------------------------|
| `BOOTCLASSPATH`  | `/system/framework/*.jar` (host Android paths)             |
| `ANDROID_DATA`   | `/data` (host path)                                        |
| `ANDROID_ROOT`   | `/system` (host path)                                      |
| `ANDROID_ART_ROOT`| `/apex/com.android.art` (host path)                       |
| `ANDROID_I18N_ROOT`| `/apex/com.android.i18n` (host path)                     |
| `ANDROID_TZDATA_ROOT`| `/apex/com.android.tzdata` (host path)                |
| `HOSTNAME`       | `localhost`                                                |

---

## 13. Security / Custom Libraries

### `/etc/ld.so.preload`

```
/home/ruusian/fix_mmap.so
```

A custom shared library `fix_mmap.so` (69816 bytes) is preloaded into every process. Source at `/home/ruusian/fix_mmap.c`. This is a custom mmap hook for Android compatibility (likely fixing mmap behavior on the 4.14 kernel).

### `/etc/environment`

Empty — no system-wide environment variables set.

---

## 14. Boot / Startup Issues

### D-Bus Failure

Repeated failures in `gui-debug.log`:
```
dbus-daemon: Failed to start message bus: Failed to bind socket "/tmp/dbus-*": Permission denied
```

**Cause:** Android's `/tmp` (symlinked to `/data/local/tmp`) has restricted permissions. D-Bus cannot create its sockets there.

### PulseAudio Connection

```
(wrapper-2.0:21933): pulseaudio-plugin-WARNING **: Disconnected from the PulseAudio server. Attempting to reconnect in 5 seconds...
```

**Cause:** PulseAudio runs on the host (Termux), and the chroot session connects via TCP `127.0.0.1:4713`. If the host PulseAudio is not running, this will repeat indefinitely.

### GPU Detection

```
[GFX1-]: glxtest: libEGL no display
[GFX1-]: glxtest: No visuals found
[GFX1-]: No GPUs detected via PCI
```

**Cause:** Inside the chroot, there is no `/dev/dri/` access unless bind-mounted, and no PCI bus is exposed. Firefox's GPU detection fails.

### Video Device Errors

```
Sandbox: Couldn't open video device /dev/video0
Sandbox: Couldn't open video device /dev/video1
```

Expected — no video devices are exposed to the chroot.

---

## 15. Chroot Tarball

A tarball `debian12-arm64.tar.gz` (133 MB) exists at the chroot root (`/data/local/tmp/chrootDebian/debian12-arm64.tar.gz`). This is the original chroot image that was extracted to create the environment.

---

## 16. Summary

| Component                  | Status                                              |
|----------------------------|-----------------------------------------------------|
| **Chroot Location**        | `/data/local/tmp/chrootDebian`                      |
| **OS**                     | Debian forky/sid (testing)                          |
| **Kernel**                 | 4.14.355 aarch64 (host)                             |
| **Architecture**           | arm64                                               |
| **Root User**              | root (uid 0)                                        |
| **Primary User**           | ruusian (uid 1000)                                  |
| **Display**                | XFCE4 via LightDM (launched from Termux)            |
| **GPU**                    | Zink over Turnip (Freedreno Vulkan on Adreno KGSL)  |
| **GPU ICD**                | `freedreno_icd.aarch64.json` (api 1.4.350)          |
| **Audio**                  | PulseAudio forwarded from host (TCP :4713)          |
| **D-Bus**                  | Installed but fails to start (/tmp permissions)     |
| **SSH**                    | OpenSSH installed, ed25519 key pair present         |
| **Browser**                | Firefox + Firefox ESR installed                     |
| **Custom Preload**         | `fix_mmap.so` (mmap compatibility hook)             |
| **Python**                 | 3.11.2                                              |
| **Network**                | Shared with host kernel                             |
| **`/dev/dri`**             | Not inside chroot (must be bind-mounted from host)  |
| **PulseAudio**             | Not running inside chroot (host provides it)        |
| **LightDM**                | Installed but unused (session started from CLI)     |
