#!/bin/bash

# --- WORKSTATION PRO SETUP MENU ---

show_menu() {
    clear
    echo -e "\e[1;34m╭──────────────────────────────────────────────────╮\e[0m"
    echo -e "\e[1;34m│\e[0m \e[1;33m       🛠️  DEBIAN DEV TOOL INSTALLER          \e[0m \e[1;34m│\e[0m"
    echo -e "\e[1;34m├──────────────────────────────────────────────────┤\e[0m"
    echo -e " \e[1;32m[1]\e[0m \e[1;37mVisual Studio Code (Stable)\e[0m"
    echo -e " \e[1;32m[2]\e[0m \e[1;37mChromium Browser (Accelerated)\e[0m"
    echo -e " \e[1;32m[3]\e[0m \e[1;37mGIMP (Image Editor)\e[0m"
    echo -e " \e[1;32m[4]\e[0m \e[1;37mPython full stack (pip, venv, dev)\e[0m"
    echo -e " \e[1;32m[5]\e[0m \e[1;37mNeofetch & HTOP (Monitoring)\e[0m"
    echo -e " \e[1;31m[6]\e[0m \e[1;37mReturn to Dashboard\e[0m"
    echo -e "\e[1;34m╰──────────────────────────────────────────────────╯\e[0m"
    read -n 1 -s -p "  Select tool to install: " tool
    echo ""
}

install_vscode() {
    echo -e "\e[1;33m[+] Installing Visual Studio Code...\e[0m"
    su -c "PATH=$PATH /data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/sh -c '
        export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        export DEBIAN_FRONTEND=noninteractive
        apt update
        apt install -y wget gpg
        mkdir -p /etc/apt/keyrings
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/packages.microsoft.gpg
        echo \"deb [arch=arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main\" > /etc/apt/sources.list.d/vscode.list
        apt update
        apt install -y code
    '"
    echo -e "\e[1;32m[✓] VS Code Installed.\e[0m"
    sleep 2
}

install_chromium() {
    echo -e "\e[1;33m[+] Installing Chromium...\e[0m"
    su -c "PATH=$PATH /data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/sh -c '
        export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        export DEBIAN_FRONTEND=noninteractive
        apt update
        apt install -y chromium
    '"
    echo -e "\e[1;32m[✓] Chromium Installed.\e[0m"
    sleep 2
}

while true; do
    show_menu
    case $tool in
        1) install_vscode ;;
        2) install_chromium ;;
        3) su -c "PATH=$PATH /data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/sh -c 'export DEBIAN_FRONTEND=noninteractive; apt update && apt install -y gimp'" ;;
        4) su -c "PATH=$PATH /data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/sh -c 'export DEBIAN_FRONTEND=noninteractive; apt update && apt install -y python3-pip python3-venv python3-dev'" ;;
        5) su -c "PATH=$PATH /data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/sh -c 'export DEBIAN_FRONTEND=noninteractive; apt update && apt install -y neofetch htop'" ;;
        6) break ;;
    esac
done
