# Week 5 Backup Strategy

## Purpose

This document defines what is backed up, how backups are created, where they are stored and how long they should be retained.

## Data to back up

The current backup script includes:

```text
/home/greendevcorp
/opt/gsx-admin
/etc/ssh
/etc/sudoers
/etc/sudoers.d
/etc/security/limits.d
/etc/profile.d/greendevcorp.sh
```

These paths represent:

- team data and shared files;
- administrative scripts;
- SSH configuration;
- sudo configuration;
- PAM resource limits;
- shared shell environment.

## Backup location

Backups are stored on the new Week 5 disk:

```text
/srv/greendev-data/backups/snapshots
```

The latest backup is available through:

```text
/srv/greendev-data/backups/snapshots/latest
```

## Backup method

The backup uses `rsync` snapshot directories.

Each snapshot is a directory named with a timestamp:

```text
YYYYMMDD-HHMMSS
```

## Incremental behavior

The script uses:

```bash
rsync -aHAX --numeric-ids --delete --relative --link-dest=<previous-snapshot>
```

This creates snapshots that look complete, while unchanged files are hard-linked to the previous snapshot. This reduces storage usage compared with copying every file every time.

## Why rsync snapshots?

Advantages:

- easy to inspect with normal shell commands;
- easy to restore individual files;
- efficient for unchanged files;
- preserves permissions and ownership;
- does not require complex backup software.

Trade-offs:

- backups are stored on the same VM in this lab;
- no encryption by default;
- no remote/offsite copy unless NFS/remote copy is added;
- hard links require care when manually editing backup snapshots.

## Integrity verification

Each snapshot includes:

```text
SHA256SUMS
```

The script verifies it with:

```bash
sha256sum -c SHA256SUMS
```

Command:

```bash
sudo ./verify_backup_integrity.sh /srv/greendev-data/backups/snapshots/latest
```

## Automation

The automated backup is managed by systemd:

```text
gsx-week5-backup.service
gsx-week5-backup.timer
```

Check:

```bash
systemctl status gsx-week5-backup.timer --no-pager
systemctl list-timers --all | grep gsx-week5-backup
journalctl -u gsx-week5-backup.service --since "today" --no-pager
```

## Retention policy

The lab retention policy is:

```text
Keep the latest 7 snapshots.
```

Cleanup command:

```bash
sudo ./cleanup_old_backups.sh 7 /srv/greendev-data
```

## 3-2-1 principle

The 3-2-1 principle means:

```text
3 copies of data
2 different media
1 offsite copy
```

This lab approximates the idea but does not fully satisfy it yet.

Current state:

| Copy | Location |
|---|---|
| Production data | VM root disk and service directories |
| Local backup | `/srv/greendev-data/backups` on new disk |
| Optional network copy | NFS/shared VM test or future remote backup |

To fully meet 3-2-1, a future improvement should add a copy outside this VM, for example another VM, external disk or cloud storage.

## RPO and RTO

### RPO — Recovery Point Objective

With daily backups:

```text
RPO ≈ up to 24 hours of possible data loss
```

### RTO — Recovery Time Objective

For this lab, recovery should take:

```text
15–30 minutes
```

depending on VM speed and amount of data.

## What could fail?

Possible failures:

- backup disk not mounted;
- backup timer disabled;
- rsync fails;
- backup fills disk;
- checksum verification fails;
- restore procedure not tested;
- NFS/network unavailable.

Mitigations:

- `verify_week5_setup.sh`;
- `backup_status.sh`;
- `journalctl` logs;
- restore tests;
- retention cleanup.
