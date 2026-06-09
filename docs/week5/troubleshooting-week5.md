# Week 5 Troubleshooting Guide

## New disk does not appear

Check:

```bash
lsblk -f
```

If it does not appear:

1. shut down VM;
2. check VirtualBox storage settings;
3. confirm the new disk is attached;
4. boot again.

## Wrong disk selected

Never format the system disk.

Before running `setup_storage_disk.sh`, check:

```bash
lsblk -f
findmnt /
```

The system disk is usually `/dev/sda`. The new disk is usually `/dev/sdb`.

## Mount does not work

Check fstab:

```bash
grep /srv/greendev-data /etc/fstab
```

Check UUID:

```bash
blkid
```

Try mounting:

```bash
sudo mount /srv/greendev-data
```

Check logs:

```bash
dmesg | tail -n 50
```

## verify_week5_setup.sh says mount is missing from fstab

Make sure the path does not include a trailing slash.

Use:

```bash
sudo ./verify_week5_setup.sh /srv/greendev-data
```

not:

```bash
sudo ./verify_week5_setup.sh /srv/greendev-data/
```

## Backup refuses to run because mountpoint is missing

The backup script intentionally refuses to write to an unmounted path to avoid filling the root filesystem.

Check:

```bash
mountpoint /srv/greendev-data
findmnt /srv/greendev-data
```

Fix:

```bash
sudo mount /srv/greendev-data
```

## Backup fails

Run manually:

```bash
sudo ./run_backup.sh /srv/greendev-data
```

Check logs:

```bash
journalctl -u gsx-week5-backup.service -n 80 --no-pager
cat /var/log/gsx/week5-backup.log
```

Common causes:

- storage disk not mounted;
- missing source directory;
- insufficient permissions;
- disk full;
- broken latest symlink.

## Integrity verification fails

Run:

```bash
sudo ./verify_backup_integrity.sh /srv/greendev-data/backups/snapshots/latest
```

If it fails:

1. do not delete older snapshots;
2. check disk errors;
3. try a previous snapshot;
4. run another backup;
5. document the failure.

## Restore test fails

Run:

```bash
sudo ./test_restore.sh /srv/greendev-data
```

Check:

```bash
ls -lh /srv/greendev-data/restore-tests
cat /var/log/gsx/week5-restore-test.log
```

Common causes:

- latest snapshot missing;
- SHA256 manifest missing;
- backup corrupted;
- insufficient disk space.

## Timer is not running

Check:

```bash
systemctl status gsx-week5-backup.timer --no-pager
systemctl list-timers --all | grep gsx-week5-backup
```

Fix:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now gsx-week5-backup.timer
```

## Service fails because scripts are missing from /opt

Reinstall the service:

```bash
sudo ./setup_backup_service.sh /srv/greendev-data
```

Then:

```bash
sudo systemctl start gsx-week5-backup.service
```

## Disk is filling up

Check:

```bash
df -h /srv/greendev-data
du -sh /srv/greendev-data/backups/snapshots/*
```

Cleanup old snapshots:

```bash
sudo ./cleanup_old_backups.sh 7 /srv/greendev-data
```

## NFS client cannot install packages

If client cannot install `nfs-common`, check NAT Internet access:

```bash
ip route
ping -c 3 8.8.8.8
ping -c 3 deb.debian.org
```

VirtualBox should have:

```text
Adapter 1: NAT
Adapter 2: Host-only
```

## NFS mount fails

On server:

```bash
sudo exportfs -v
systemctl status nfs-server --no-pager
```

On client:

```bash
command -v mount.nfs
ping -c 3 <SERVER_IP>
sudo mount -t nfs -o vers=4 <SERVER_IP>:/srv/greendev-data/shared /mnt/greendev-shared
```

## Full Week 5 repair

```bash
cd scripts/week5
sudo ./setup_backup_directories.sh /srv/greendev-data
sudo ./setup_backup_service.sh /srv/greendev-data
sudo ./run_backup.sh /srv/greendev-data
sudo ./test_restore.sh /srv/greendev-data
sudo ./verify_week5_setup.sh /srv/greendev-data
```
