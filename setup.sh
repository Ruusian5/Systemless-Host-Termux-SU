#!/bin/bash
echo '[+] Installing Pro-Termux-Harden v12.7...'
cp scripts/*.sh ~/
cp configs/bashrc.example ~/.bashrc
chmod +x ~/*.sh
echo '[✓] Installation Complete. Restart Termux to see the HUD.'
