#!/bin/bash
# --- APP MANAGER v1.0 ---
# GUI-based package manager for Debian chroot
# Uses dialog/whiptail for terminal UI, or falls back to simple menu

C_BOLD='\e[1m'; C_GREEN='\e[38;5;82m'; C_CYAN='\e[38;5;39m'
C_RED='\e[38;5;196m'; C_ORANGE='\e[38;5;208m'; C_PURPLE='\e[38;5;141m'; NC='\e[0m'
DEBIANPATH="/data/local/tmp/chrootDebian"
# Ensure /data is remounted suid so chroot su/sudo works
su -c "/data/data/com.termux/files/usr/bin/busybox mount -o remount,dev,suid /data" 2>/dev/null || true

CHROOT_M=0; su -c "grep -q '/data/local/tmp/chrootDebian/dev ' /proc/mounts" 2>/dev/null && CHROOT_M=1
if [ $CHROOT_M -eq 0 ]; then
    echo -e "${C_RED}[!] Chroot not mounted. Run 'Mount Chroot' first.${NC}"
    exit 1
fi

# Run apt command inside chroot
chroot_apt() {
    su -c "chroot $DEBIANPATH /bin/bash -c '
        export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        export DEBIAN_FRONTEND=noninteractive
        apt-get -o APT::Status-Fd=1 $1
    '" 2>&1
}

# Run command inside chroot
chroot_cmd() {
    su -c "chroot $DEBIANPATH /bin/bash -c '
        export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        export DEBIAN_FRONTEND=noninteractive
        $1
    '" 2>&1
}

# Check if dialog is available
HAS_DIALOG=0
su -c "chroot $DEBIANPATH /bin/bash -c 'which dialog 2>/dev/null'" >/dev/null 2>&1 && HAS_DIALOG=1

# App categories for browsing
show_categories() {
    if [ $HAS_DIALOG -eq 1 ]; then
        CHOICE=$(su -c "chroot $DEBIANPATH /bin/bash -c 'export TERM=xterm; dialog --stdout --title \"App Manager\" --menu \"Browse by Category\" 20 50 12 \
            1 \"Web Browsers\" \
            2 \"Text Editors\" \
            3 \"Media Players\" \
            4 \"Development Tools\" \
            5 \"System Tools\" \
            6 \"Graphics\" \
            7 \"Network Tools\" \
            8 \"Games\" \
            9 \"All Packages\" \
            0 \"Search...\"'" 2>&1)
    else
        echo ""
        echo -e "${C_CYAN}${C_BOLD}╔══════════════════════════════════════════╗${NC}"
        echo -e "${C_CYAN}${C_BOLD}║         APP MANAGER v1.0                 ║${NC}"
        echo -e "${C_CYAN}${C_BOLD}╚══════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${C_GREEN}[1]${NC} Web Browsers       ${C_GREEN}[2]${NC} Text Editors"
        echo -e "  ${C_GREEN}[3]${NC} Media Players      ${C_GREEN}[4]${NC} Development Tools"
        echo -e "  ${C_GREEN}[5]${NC} System Tools       ${C_GREEN}[6]${NC} Graphics"
        echo -e "  ${C_GREEN}[7]${NC} Network Tools      ${C_GREEN}[8]${NC} Games"
        echo -e "  ${C_GREEN}[9]${NC} All Packages       ${C_GREEN}[0]${NC} Search..."
        echo ""
        echo -ne "${C_BOLD}Select: ${NC}"
        read -r CHOICE
    fi
    echo "$CHOICE"
}

# Show packages in a category
show_category_packages() {
    local category=$1
    local packages=""

    case $category in
        1) # Web Browsers
            packages="chromium firefox epiphany-browser lynx w3m"
            ;;
        2) # Text Editors
            packages="vim nano emacs geany mousepad"
            ;;
        3) # Media Players
            packages="vlc mpv ffmpeg ffplay celluloid"
            ;;
        4) # Development Tools
            packages="gcc g++ make cmake git python3 python3-pip nodejs default-jdk"
            ;;
        5) # System Tools
            packages="htop neofetch tmux screen timeshift gparted"
            ;;
        6) # Graphics
            packages="gimp inkscape imagemagick feh sxiv"
            ;;
        7) # Network Tools
            packages="nmap wireshark curl wget net-tools openssh-client"
            ;;
        8) # Games
            packages="nethack wesnoth frozen-bubble 2048"
            ;;
        9) # All - show installed
            show_installed_packages
            return
            ;;
        0) # Search
            search_packages
            return
            ;;
    esac

    echo ""
    echo -e "${C_CYAN}${C_BOLD}── Available: $category ──${NC}"
    echo ""

    for pkg in $packages; do
        STATUS=$(chroot_cmd "dpkg -l $pkg 2>/dev/null | grep -c '^ii'")
        VERSION=$(chroot_cmd "dpkg -s $pkg 2>/dev/null | grep '^Version:' | awk '{print \$2}'" 2>/dev/null | tr -d '\r')
        if [ "$STATUS" = "1" ]; then
            echo -e "  ${C_GREEN}✓${NC} $pkg ${C_CYAN}$VERSION${NC}"
        else
            echo -e "  ${C_ORANGE}○${NC} $pkg"
        fi
    done

    echo ""
    echo -e "  ${C_GREEN}[i]${NC} Install    ${C_RED}[r]${NC} Remove    ${C_ORANGE}[u]${NC} Update    ${C_CYAN}[s]${NC} Search"
    echo -ne "${C_BOLD}Action (pkg name or i/r/u/s): ${NC}"
    read -r action

    case $action in
        i|I)
            echo -e "${C_GREEN}Package name to install: ${NC}"
            read -r pkg_name
            [ -n "$pkg_name" ] && install_package "$pkg_name"
            ;;
        r|R)
            echo -e "${C_RED}Package name to remove: ${NC}"
            read -r pkg_name
            [ -n "$pkg_name" ] && remove_package "$pkg_name"
            ;;
        u|U)
            update_packages
            ;;
        s|S)
            search_packages
            ;;
        *)
            # Assume it's a package name — install it
            [ -n "$action" ] && install_package "$action"
            ;;
    esac
}

# Install a package
install_package() {
    local pkg=$1
    echo ""
    echo -e "${C_GREEN}[+] Installing: $pkg${NC}"
    echo -e "${C_ORANGE}  This may take a while...${NC}"
    echo ""
    chroot_apt "install -y $pkg" | tail -20
    echo ""
    echo -e "${C_GREEN}[✓] Done${NC}"
}

# Remove a package
remove_package() {
    local pkg=$1
    echo ""
    echo -e "${C_RED}[-] Removing: $pkg${NC}"
    chroot_apt "remove -y $pkg" | tail -10
    echo ""
    echo -e "${C_GREEN}[✓] Done${NC}"
}

# Update package lists
update_packages() {
    echo ""
    echo -e "${C_ORANGE}[u] Updating package lists...${NC}"
    chroot_apt "update" | tail -10
    echo ""
    echo -e "${C_GREEN}[✓] Done${NC}"
}

# Search packages
search_packages() {
    echo ""
    echo -ne "${C_BOLD}Search term: ${NC}"
    read -r term
    if [ -n "$term" ]; then
        echo ""
        echo -e "${C_CYAN}${C_BOLD}── Search: $term ──${NC}"
        chroot_cmd "apt-cache search $term 2>/dev/null" | head -30
        echo ""
        echo -ne "${C_BOLD}Package name to install (or Enter to go back): ${NC}"
        read -r pkg_name
        [ -n "$pkg_name" ] && install_package "$pkg_name"
    fi
}

# Show installed packages
show_installed_packages() {
    echo ""
    echo -e "${C_CYAN}${C_BOLD}── Installed Packages ──${NC}"
    chroot_cmd "dpkg -l 2>/dev/null | grep '^ii' | awk '{print \$2, \$3}'" | head -50
    echo ""
    echo -e "${C_ORANGE}  (Showing first 50 — use Search for specific packages)${NC}"
    echo ""
    echo -ne "${C_BOLD}Package name to remove (or Enter to go back): ${NC}"
    read -r pkg_name
    [ -n "$pkg_name" ] && remove_package "$pkg_name"
}

# Main loop
while true; do
    CHOICE=$(show_categories)
    case $CHOICE in
        1|2|3|4|5|6|7|8|9|0)
            show_category_packages "$CHOICE"
            ;;
        q|Q)
            break
            ;;
        *)
            echo -e "${C_RED}Invalid choice${NC}"
            ;;
    esac
    echo ""
    echo -ne "${C_ORANGE}Press Enter to continue...${NC}"
    read -r
    clear
done
