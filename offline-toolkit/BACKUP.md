# 💾 Backup Strategy

To ensure your data and workstation configurations are safe, follow this enterprise backup strategy.

## Creating a Full Offline Snapshot
If you want to backup the **entire** Debian system (including installed tools and custom environment), use the `zstd` archiver:

```bash
# 1. Stop all active sessions to safely unmount hardware interfaces
bash ~/stop-debian.sh

# 2. Archive the chroot directory
su -c "tar -I 'zstd -T0 -10' -cpf /sdcard/workstation-backup-$(date +%F).tar.zst -C /data/local/tmp chrootDebian"
```

## Creating a User Data Backup
If you only need to backup your user files and projects (`/home/Ruusian5`):

```bash
su -c "tar -czvf /sdcard/Ruusian5-home-backup.tar.gz -C /data/local/tmp/chrootDebian/home Ruusian5"
```
This is much smaller and recommended for daily backups. Store these on a separate drive or cloud storage.
