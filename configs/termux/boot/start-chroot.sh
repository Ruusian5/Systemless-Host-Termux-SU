#!/data/data/com.termux/files/usr/bin/bash
# Auto-start Debian chroot desktop on boot (Termux:Boot)
# Compatible with PRO WORKSTATION DASHBOARD startup chain

# Brief delay to let system settle after boot
sleep 5

# Source profile for PATH
. /data/data/com.termux/files/home/.bashrc 2>/dev/null || true

# Launch the full desktop startup
bash /data/data/com.termux/files/home/startxfce4_chrootDebian.sh
