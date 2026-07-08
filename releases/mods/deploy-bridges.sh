#!/bin/bash
# --- DEPLOY BRIDGES (v1.0) ---
# Deploys all Termux↔Debian bridge scripts to runtime locations.
# Run this from Termux to (re)install everything.

REPO_SCRIPTS="/data/data/com.termux/files/home/Systemless-Host-Termux-SU/scripts"
REPO_DEBIAN="/data/data/com.termux/files/home/Systemless-Host-Termux-SU/configs/debian"
REPO_BOOT="/data/data/com.termux/files/home/Systemless-Host-Termux-SU/configs/termux/boot"
DEBIANPATH="/data/local/tmp/chrootDebian"

echo "╔══════════════════════════════════════════╗"
echo "║       Deploying Termux↔Debian Bridges   ║"
echo "╚══════════════════════════════════════════╝"

# ── Step 1: Termux-side scripts (~/) ──
echo ""
echo "[1/4] Deploying Termux-side bridge scripts..."
for script in battery-bridge.sh startxfce4_chrootDebian.sh; do
    src="$REPO_SCRIPTS/$script"
    dst="$HOME/$script"
    if [ -f "$src" ]; then
        cp "$src" "$dst"
        chmod +x "$dst"
        echo "  ✓ $script"
    else
        echo "  ✗ $script NOT FOUND in repo, skipping"
    fi
done

# ── Step 2: Chroot-side scripts (/usr/local/bin) ──
echo ""
echo "[2/4] Deploying chroot-side scripts..."
if su -c "test -d $DEBIANPATH/usr/local/bin" 2>/dev/null; then
    for script in battery-monitor.sh android user-session.sh; do
        src="$REPO_DEBIAN/usr/local/bin/$script"
        dst_chroot="$DEBIANPATH/usr/local/bin/$script"
        if [ -f "$src" ]; then
            su -c "cp '$src' '$dst_chroot' && chmod +x '$dst_chroot'" 2>/dev/null && echo "  ✓ $script" || echo "  ✗ $script (copy failed)"
        else
            echo "  ✗ $script NOT FOUND in repo, skipping"
        fi
    done
else
    echo "  ✗ Chroot not mounted at $DEBIANPATH — mount first with mount-debian.sh"
fi

# ── Step 3: Auto-boot script (~/.termux/boot/) ──
echo ""
echo "[3/4] Deploying auto-boot script..."
mkdir -p "$HOME/.termux/boot"
boot_src="$REPO_BOOT/start-chroot.sh"
boot_dst="$HOME/.termux/boot/start-chroot.sh"
if [ -f "$boot_src" ]; then
    cp "$boot_src" "$boot_dst"
    chmod +x "$boot_dst"
    echo "  ✓ start-chroot.sh"
else
    echo "  ✗ Config boot script NOT FOUND, skipping"
fi

# ── Step 4: Dashboard (cmds.sh) deployed as user convenience ──
echo ""
echo "[4/4] Deploying dashboard..."
cmds_src="$REPO_SCRIPTS/cmds.sh"
cmds_dst="$HOME/cmds.sh"
if [ -f "$cmds_src" ]; then
    cp "$cmds_src" "$cmds_dst"
    chmod +x "$cmds_dst"
    echo "  ✓ cmds.sh (dashboard)"
else
    echo "  ✗ cmds.sh NOT FOUND, skipping"
fi

echo ""
echo "✓ Deploy complete. Run 'cmds.sh' to launch the dashboard."
