# 🚚 Migration Guide

## Moving to a New Device

If you are upgrading to a new Android phone or tablet, you can bring your entire workstation with you natively.

### Pre-Requisites on the New Device
1. The new device **must** be rooted.
2. The new device **must** use an `aarch64` (ARM64) processor.
3. Install Termux.

### Migration Steps
1. On your **OLD** device, create a full snapshot:
   ```bash
   bash ~/stop-debian.sh
   su -c "tar -I 'zstd -T0 -10' -cpf /sdcard/migration.tar.zst -C /data/local/tmp chrootDebian"
   ```
2. Transfer `migration.tar.zst` to your new device.
3. On the **NEW** device, clone the toolkit repository:
   ```bash
   git clone https://github.com/Ruusian5/Systemless-Host-Termux-SU.git
   cd Systemless-Host-Termux-SU/offline-toolkit
   ```
4. Run the restore command:
   ```bash
   ./restore.sh /sdcard/migration.tar.zst
   ```
5. Once complete, the installer will bridge the new host environment to your existing Debian OS. Start your session with `agy`.
