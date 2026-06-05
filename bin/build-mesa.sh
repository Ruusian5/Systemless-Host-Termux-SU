#!/data/data/com.termux/files/usr/bin/bash
# --- CUSTOM MESA DRIVER BUILDER (TURNIP/KGSL) ---
# This script compiles the Mesa graphics stack directly from source code
# on your specific hardware. This is the closest equivalent to "building
# a driver from scratch" for an Adreno GPU on Linux.

DEBIANPATH="/data/local/tmp/chrootDebian"

echo -e "\e[1;36m[+] Initializing Custom Driver Build Environment...\e[0m"

# 1. Install Build Dependencies inside Debian
echo -e "\e[1;33m[~] Installing compilers and headers (This will take a while)...\e[0m"
su -c "PATH=\$PATH /data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin DEBIAN_FRONTEND=noninteractive /usr/bin/apt update"

su -c "PATH=\$PATH /data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin DEBIAN_FRONTEND=noninteractive /usr/bin/apt install -y \
    git build-essential meson ninja-build pkg-config \
    python3-mako python3-packaging python3-pygments \
    libvulkan-dev libwayland-dev libx11-dev libxcb*-dev \
    libxext-dev libxrandr-dev libxrender-dev libxshmfence-dev \
    libxxf86vm-dev x11proto-dev libdrm-dev libelf-dev \
    libunwind-dev flex bison wayland-protocols"

# 2. Setup Build Script inside Debian
echo -e "\e[1;33m[~] Preparing Source Code Fetcher...\e[0m"
su -c "cat > $DEBIANPATH/root/compile_mesa.sh << 'INNER_EOF'
#!/bin/bash
cd /root
echo \"[+] Cloning Mesa Source Code...\"
# We clone the main Mesa repository. Note: For absolute cutting-edge KGSL patches, 
# developers sometimes use specific forks, but upstream Mesa contains Turnip.
if [ ! -d \"mesa\" ]; then
    git clone --depth 1 https://gitlab.freedesktop.org/mesa/mesa.git
fi
cd mesa

echo \"[+] Configuring Custom Build (Turnip + Zink)...\"
# We configure meson to ONLY build the drivers we need for your Adreno.
# This saves compile time and reduces bloat.
meson setup build \
    -Dprefix=/usr/local \
    -Dplatforms=x11,wayland \
    -Dgallium-drivers=zink,freedreno,swrast \
    -Dvulkan-drivers=freedreno \
    -Dfreedreno-kmds=kgsl \
    -Dbuildtype=release \
    -Dglx=dri \
    -Dshared-glapi=enabled \
    -Degl=enabled \
    -Dgles1=enabled \
    -Dgles2=enabled

echo \"[+] Compiling Custom Drivers (This may take 1-3 hours depending on CPU)...\"
ninja -C build

echo \"[+] Installing Custom Drivers to System...\"
ninja -C build install

echo \"[✓] Custom Driver Compilation Complete!\"
INNER_EOF"

su -c "chmod +x $DEBIANPATH/root/compile_mesa.sh"

echo -e "\e[1;32m[✓] Build environment ready.\e[0m"
echo -e "\e[1;35mTo start the compilation, run:\e[0m"
echo -e "su -c \"chroot $DEBIANPATH /root/compile_mesa.sh\""
echo -e "\e[1;31mWARNING: Compiling Mesa from source is incredibly CPU and RAM intensive. It may take hours and cause the device to heat up significantly.\e[0m"
