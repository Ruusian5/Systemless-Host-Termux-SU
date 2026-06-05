#!/bin/bash
echo "[+] Preparing to reinstall Hermes..."
cd ~
[ -d ".hermes" ] && rm -rf .hermes
# Assuming standard installation command based on typical hermes deployment
curl -sSL https://raw.githubusercontent.com/Project-Hermes/hermes/main/install.sh | bash
