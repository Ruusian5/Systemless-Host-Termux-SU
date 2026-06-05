#!/bin/sh
# Run once at first session start to finalize setup
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

# Set default MIME associations
xdg-mime default xfce4-terminal.desktop application/x-terminal-emulator 2>/dev/null || true
xdg-mime default firefox-esr.desktop x-scheme-handler/http 2>/dev/null || true
xdg-mime default firefox-esr.desktop x-scheme-handler/https 2>/dev/null || true
xdg-mime default thunar.desktop inode/directory 2>/dev/null || true

# Enable thunar volume management
xfconf-query -c thunar -p /last-show-hidden -n -t bool -s true 2>/dev/null || true
xfconf-query -c thunar -p /last-side-pane -n -t string -s "ThunarShortcutsPane" 2>/dev/null || true
xfconf-query -c thunar -p /misc-open-as-root -n -t bool -s false 2>/dev/null || true

# Mark done
touch /home/ruusian/.config/.first-boot-done
