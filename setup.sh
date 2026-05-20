#!/bin/bash

# --- PRO-TERMUX-HARDEN MASTER SETUP (V1.0) ---
# High-Performance Linux Autonomy for Android

C1='\e[1;38;5;208m' # Orange
C2='\e[1;38;5;39m'  # Cyan
C3='\e[1;38;5;82m'  # Green
C4='\e[1;38;5;196m' # Red
NC='\e[0m'

clear
echo -e "${C2}┌──────────────────────────────────────────────────────────┐${NC}"
echo -e "${C2}│${NC} ${C1}        PRO-TERMUX HARDENED SYSTEM INSTALLER          ${NC} ${C2}│${NC}"
echo -e "${C2}└──────────────────────────────────────────────────────────┘${NC}"

# 1. PREREQUISITE CHECKS
echo -e "\n${C2}[*] Performing System Environment Check...${NC}"

# Check Root
if [ "$(whoami)" != "root" ] && ! command -v su >/dev/null; then
    echo -e "${C4}[!] ERROR: This system requires ROOT for the Kernel Bridge.${NC}"
    echo -e "${C5}Please root your device before proceeding.${NC}"
    exit 1
else
    echo -e "${C3}[✓] Root Access Available.${NC}"
fi

# Check Termux-X11
if ! command -v termux-x11 >/dev/null; then
    echo -e "${C4}[!] WARNING: Termux-X11 is not installed.${NC}"
    echo -e "${C5}You will need it for the Graphical Workstation (Option 1).${NC}"
fi

# 2. INSTALLATION MENU
echo -e "\n${C1}CHOOSE INSTALLATION TYPE:${NC}"
echo -e " [1] ${C2}FULL INSTALL${NC} (Hardened Scripts + Kernel Bridge + HUD)"
echo -e " [2] ${C2}UPDATE ONLY${NC}  (Sync existing scripts to latest v11.2)"
echo -e " [3] ${C2}EXIT${NC}"

echo -en "\n${C1}SELECT > ${NC}"
read opt

case $opt in
    1)
        echo -e "\n${C2}[+] Initializing Full Hardened Deployment...${NC}"
        cp ../scripts/*.sh ~/
        cp ../configs/bashrc.example ~/.bashrc
        chmod +x ~/*.sh
        echo -e "${C3}[✓] Hardened scripts deployed to home directory.${NC}"
        echo -e "${C3}[✓] .bashrc configured for non-blocking HUD startup.${NC}"
        echo -e "\n${C1}Please restart Termux to activate your new system!${NC}"
        ;;
    2)
        echo -e "\n${C2}[+] Syncing Scripts to v11.2...${NC}"
        cp ../scripts/*.sh ~/
        chmod +x ~/*.sh
        echo -e "${C3}[✓] Scripts updated successfully.${NC}"
        ;;
    *)
        echo "Exiting installer."
        exit 0
        ;;
esac
