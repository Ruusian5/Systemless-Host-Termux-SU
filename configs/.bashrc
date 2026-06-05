# --- MASTER CONFIGURATION .BASHRC ---

# CORE PATHS
REPO_DIR="/data/data/com.termux/files/home/Systemless-Host-Termux-SU"
SCRIPT_DIR="$REPO_DIR/scripts"

# System HUD Aliases (Instant Access)
# 1. Launch XFCE Workstation
alias 1='bash $SCRIPT_DIR/startxfce4_chrootDebian.sh'

# 2. Force Reset
alias 2='bash $SCRIPT_DIR/stop-debian.sh'

# 3. CLI Terminal
alias 3='bash $SCRIPT_DIR/cli-bridge.sh'

# 4. Debian Maintenance
alias 4='bash $SCRIPT_DIR/mount-debian.sh && su -c "/data/data/com.termux/files/usr/bin/busybox chroot /data/local/tmp/chrootDebian /usr/bin/env -i HOME=/root TERM=\$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TMPDIR=/tmp DEBIAN_FRONTEND=noninteractive /usr/bin/sh -c \"apt update && apt upgrade -y && apt autoremove -y && apt clean\""'

# 5. Tool Installer
alias 5='bash $SCRIPT_DIR/install-tools.sh'

# 6. Exit
alias 6='exit'

# Named Overrides
alias start-desktop='1'
alias stop-desktop='2'
alias debian-login='3'
alias debian-update='4'
alias install-tools='5'
alias cmds='bash $SCRIPT_DIR/cmds.sh'

# Custom high-tech prompt
PS1='\e[1;38;5;208m[PRO-TERMUX]\e[0m:\e[1;36m\w\e[0m\$ '

# Auto-mount and launch HUD as banner
if [[ $- == *i* ]]; then
    {
        bash $SCRIPT_DIR/mount-debian.sh > /dev/null 2>&1
    } & disown
    timeout 3s bash $SCRIPT_DIR/cmds.sh --once
fi
