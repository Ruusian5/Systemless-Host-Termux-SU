#!/bin/bash
# --- PRO WORKSTATION AUTOMATED INSTALLER ---
# Optimizes Termux + Debian Chroot for Zink/Turnip Hardware Acceleration

set -e

C_BOLD='\e[1m'
C_CYAN='\e[38;5;39m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
NC='\e[0m'

echo -e "${C_CYAN}${C_BOLD}>>> Initializing Pro Workstation Setup...${NC}"

# 1. Root Verification
if [[ $(id -u) -ne 0 ]] && ! command -v su > /dev/null; then
    echo -e "${C_RED}[!] Error: This setup requires SuperUser (Root) access.${NC}"
    exit 1
fi

# 2. Termux Dependency Injection
echo -e "\n${C_BOLD}[1/5] Injecting Termux Dependencies...${NC}"
pkg update -y
pkg install -y git busybox xclip pulseaudio mesa-zink virglrenderer-android termux-x11-nightly

# 3. Environment Synchronization
echo -e "\n${C_BOLD}[2/5] Deploying System Management Scripts...${NC}"
REPO_DIR=$(pwd)
cp -v scripts/*.sh ~/
chmod +x ~/*.sh

# 4. Shell Integration
echo -e "\n${C_BOLD}[3/5] Configuring Shell (.bashrc)...${NC}"
if ! grep -q "cmds.sh" ~/.bashrc; then
    cat << 'EOF' >> ~/.bashrc

# --- PRO WORKSTATION HUD ---
alias agy='bash ~/cmds.sh'
alias 1='bash ~/startxfce4_chrootDebian.sh'
alias 2='bash ~/stop-debian.sh'
alias 3='bash ~/mount-debian.sh && su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/local/bin/v3-cli.sh"'

if [[ $- == *i* ]]; then
    { bash ~/mount-debian.sh > /dev/null 2>&1; } & disown
    timeout 3s bash ~/cmds.sh --once
fi
EOF
    echo -e "  [✓] Aliases and banner added to .bashrc"
fi

# 5. Chroot Hardening & Fixes
echo -e "\n${C_BOLD}[4/5] Synchronizing Debian Guest Environment...${NC}"
DEBIANPATH="/data/local/tmp/chrootDebian"

if [ ! -d "$DEBIANPATH" ]; then
    echo -e "${C_RED}[!] Warning: Debian chroot not found at $DEBIANPATH${NC}"
    echo -e "Please ensure your Debian chroot is extracted to that location."
else
    bash ~/mount-debian.sh
    
    # Sync internal configs
    su -c "
        mkdir -p $DEBIANPATH/etc/profile.d/ $DEBIANPATH/usr/local/bin/ $DEBIANPATH/home/ruusian/
        cp -v $REPO_DIR/configs/debian/etc/profile.d/*.sh $DEBIANPATH/etc/profile.d/
        cp -v $REPO_DIR/configs/debian/usr/local/bin/*.sh $DEBIANPATH/usr/local/bin/
        cp -v $REPO_DIR/configs/debian/home/ruusian/fix_mmap.c $DEBIANPATH/home/ruusian/
        chmod +x $DEBIANPATH/usr/local/bin/*.sh
        
        # Install GCC and build the Kernel Fix
        echo -e '\n${C_BOLD}[5/5] Building Kernel Bypass Library...${NC}'
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        /data/data/com.termux/files/usr/bin/busybox chroot $DEBIANPATH /usr/bin/sh -c '
            apt update
            apt install -y gcc libc6-dev
            gcc -shared -fPIC -ldl /home/ruusian/fix_mmap.c -o /home/ruusian/fix_mmap.so
            echo \"/home/ruusian/fix_mmap.so\" > /etc/ld.so.preload
        '
    "
fi

echo -e "\n${C_GREEN}${C_BOLD}>>> SETUP COMPLETE! <<<${NC}"
echo -e "Please restart Termux and type ${C_CYAN}'agy'${NC} to launch your dashboard."
