#!/bin/bash

# --- PRO-TERMUX-HARDEN BACKUP SYSTEM (V1.0) ---
# Creates a portable snapshot of your exact environment

DEBIANPATH="/data/local/tmp/chrootDebian"
BACKUP_DIR="/sdcard/ProTermux-Backups"

echo -e "\e[1;33m[+] Initializing Full System Backup...\e[0m"
mkdir -p "$BACKUP_DIR"

# 1. Backup Hardened Scripts & Configs
echo -e "\e[1;36m[→]\e[0m Backing up Termux Home Configs..."
tar -czf "$BACKUP_DIR/termux_home.tar.gz" -C ~ .bashrc cmds.sh mount-debian.sh startxfce4_chrootDebian.sh stop-debian.sh install-tools.sh Pro-Termux-Harden

# 2. Backup Debian Chroot (Requires Root)
echo -e "\e[1;36m[→]\e[0m Compressing Debian Chroot (This may take a few minutes)..."
su -c "tar --exclude='dev/*' --exclude='proc/*' --exclude='sys/*' --exclude='tmp/*' --exclude='run/*' --exclude='sdcard/*' -czf '$BACKUP_DIR/debian_chroot.tar.gz' -C '$DEBIANPATH' ."

echo -e "\e[1;32m[✓] Backup Complete!\e[0m"
echo -e "\e[1;35mLocation:\e[0m $BACKUP_DIR"
echo -e "\e[1;35mFiles:\e[0m termux_home.tar.gz, debian_chroot.tar.gz"
