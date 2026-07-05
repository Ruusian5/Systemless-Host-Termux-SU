#!/bin/bash
# --- FULL ENVIRONMENT BACKUP v1.0 ---
# Snapshots Termux scripts, chroot configs, package lists, and Hermes settings
# Usage: bash backup-all.sh [--full] [--no-push]

set -euo pipefail

C_BOLD='\e[1m'
C_GREEN='\e[38;5;82m'
C_RED='\e[38;5;196m'
C_ORANGE='\e[38;5;208m'
C_CYAN='\e[38;5;39m'
NC='\e[0m'

BACKUP_DIR="/sdcard/backups/$(date +%Y%m%d_%H%M%S)"
DEBIANPATH="/data/local/tmp/chrootDebian"
CHROOT_DISTRO="/data/local/chroot-distro/ubuntu"
REPO_DIR="$HOME/Systemless-Host-Termux-SU"
DO_FULL=false
DO_PUSH=true
ERRORS=0

for arg in "$@"; do
    case $arg in
        --full)   DO_FULL=true ;;
        --no-push) DO_PUSH=false ;;
    esac
done

mkdir -p "$BACKUP_DIR"/{scripts,configs,packages,hermes}
log()  { echo -e "${C_GREEN}[✓]${NC} $1"; }
warn() { echo -e "${C_ORANGE}[!]${NC} $1"; }
fail() { echo -e "${C_RED}[✗]${NC} $1"; ERRORS=$((ERRORS+1)); }

echo -e "${C_BOLD}${C_CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║       FULL ENVIRONMENT BACKUP v1.0      ║"
echo "║     $BACKUP_DIR"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ── 1. Termux Scripts ────────────────────────────────────────────────
echo -e "\n${C_BOLD}[1/6] Backing up Termux scripts...${NC}"
mkdir -p "$BACKUP_DIR/scripts"
cp "$HOME"/*.sh "$BACKUP_DIR/scripts/" 2>/dev/null && log "Scripts copied" || warn "No scripts found"

# ── 2. Systemless Repo ───────────────────────────────────────────────
echo -e "\n${C_BOLD}[2/6] Updating Systemless-Host-Termux-SU repo...${NC}"
if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    git add -A 2>/dev/null && git commit -m "backup: snapshot $(date +%Y%m%d_%H%M%S)" --allow-empty 2>/dev/null && log "Repo committed" || warn "Nothing new to commit"
    if $DO_PUSH; then
        git push origin main 2>/dev/null && log "Repo pushed to origin" || warn "Push failed (offline?)"
    fi
else
    fail "Systemless repo not found at $REPO_DIR"
fi

# ── 3. Chroot Package Lists ──────────────────────────────────────────
echo -e "\n${C_BOLD}[3/6] Snapshotting chroot package lists...${NC}"
if [ -d "$DEBIANPATH" ]; then
    su -c "busybox chroot $DEBIANPATH dpkg -l" > "$BACKUP_DIR/packages/debian-packages.txt" 2>/dev/null && log "Debian packages saved" || warn "Debian dpkg failed (chroot not mounted?)"
    su -c "busybox chroot $DEBIANPATH pip3 list 2>/dev/null" > "$BACKUP_DIR/packages/debian-pip.txt" 2>/dev/null && log "Debian pip packages saved" || true
fi
if [ -d "$CHROOT_DISTRO" ]; then
    su -c "chroot $CHROOT_DISTRO dpkg -l" > "$BACKUP_DIR/packages/ubuntu-packages.txt" 2>/dev/null && log "Ubuntu packages saved" || true
fi

# ── 4. Hermes Config Snapshot ────────────────────────────────────────
echo -e "\n${C_BOLD}[4/6] Snapshotting Hermes config...${NC}"
HERMES_DIR="$DEBIANPATH/home/ruusian/.hermes"
if [ -d "$HERMES_DIR" ]; then
    cp "$HERMES_DIR/config.yaml" "$BACKUP_DIR/hermes/config.yaml" 2>/dev/null && log "Hermes config saved"
    cp "$HERMES_DIR/SOUL.md" "$BACKUP_DIR/hermes/" 2>/dev/null || true
    su -c "cat $HERMES_DIR/.env" > "$BACKUP_DIR/hermes/env.txt" 2>/dev/null || warn "Hermes .env not accessible"
    su -c "busybox chroot $DEBIANPATH /home/ruusian/.hermes/hermes-agent/venv/bin/pip3 list --format=columns 2>/dev/null" > "$BACKUP_DIR/hermes/hermes-pip.txt" 2>/dev/null && log "Hermes pip packages saved" || true
else
    warn "Hermes config directory not found"
fi

# ── 5. Chroot Tarball (--full only) ──────────────────────────────────
echo -e "\n${C_BOLD}[5/6] Chroot backup...${NC}"
if $DO_FULL; then
    if [ -d "$DEBIANPATH" ]; then
        BACKUP_FILE="$BACKUP_DIR/debian-chroot.tar.gz"
        warn "Creating full Debian chroot tarball (this may take several minutes)..."
        su -c "/data/data/com.termux/files/usr/bin/tar \
          --warning=no-file-changed \
          --exclude='dev/*' --exclude='proc/*' --exclude='sys/*' \
          --exclude='system/*' --exclude='vendor/*' --exclude='apex/*' --exclude='linkerconfig/*' \
          --exclude='sdcard/*' \
          --exclude='data/data/com.termux/*' \
          --exclude='tmp/*' \
          -czf $BACKUP_FILE -C /data/local/tmp chrootDebian" 2>/dev/null && log "Debian chroot saved to $BACKUP_FILE" || fail "Debian chroot tarball failed"
    fi
    if [ -d "$CHROOT_DISTRO" ]; then
        BACKUP_FILE="$BACKUP_DIR/ubuntu-chroot.tar.gz"
        warn "Creating full Ubuntu chroot tarball..."
        su -c "tar -czf $BACKUP_FILE -C /data/local/chroot-distro ubuntu 2>/dev/null" && log "Ubuntu chroot saved to $BACKUP_FILE" || fail "Ubuntu chroot tarball failed"
    fi
else
    warn "Skipping chroot tarballs (use --full to include them)"
fi

# ── 6. Chroot config manifest ────────────────────────────────────────
echo -e "\n${C_BOLD}[6/6] Generating manifest...${NC}"
{
    echo "Backup Date: $(date)"
    echo "Device: $(getprop ro.product.model 2>/dev/null || echo 'unknown')"
    echo "Android: $(getprop ro.build.version.release 2>/dev/null || echo 'unknown')"
    echo "Kernel: $(uname -r 2>/dev/null || echo 'unknown')"
    echo "Arch: $(uname -m 2>/dev/null || echo 'unknown')"
    echo ""
    echo "=== Backup Contents ==="
    find "$BACKUP_DIR" -type f | sort
} > "$BACKUP_DIR/MANIFEST.txt"
log "Manifest written"

# ── Summary ──────────────────────────────────────────────────────────
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${C_GREEN}${C_BOLD}>>> BACKUP COMPLETE <<<${NC}"
else
    echo -e "${C_ORANGE}${C_BOLD}>>> BACKUP FINISHED WITH $ERRORS WARNINGS <<<${NC}"
fi
echo -e "  Location: ${C_CYAN}$BACKUP_DIR${NC}"
echo -e "  Quick restore: ${C_ORANGE}cp -r $BACKUP_DIR/scripts/* ~/${NC}"
echo ""
echo -e "  ${C_BOLD}Private repo setup:${NC}"
echo -e "  If you want a dedicated private git repo for full env tracking:"
echo -e "    ${C_CYAN}cd ~ && git init && git add -A && git commit -m \"initial env snapshot\"${NC}"
echo -e "    ${C_CYAN}gh repo create env-backup --private --push --source=.${NC}"
