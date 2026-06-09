# Week 5 — Storage, Backup and Recovery

## Goal

The goal of Week 5 is to protect GreenDevCorp's data by adding dedicated storage, implementing automated backups, verifying backup integrity and proving that data can be restored.

This week focuses on one of the most important sysadmin responsibilities: data must not be lost.

## Implemented components

Week 5 implements:

- a new VirtualBox disk;
- an ext4 filesystem;
- a persistent mount using `/etc/fstab`;
- a storage root at `/srv/greendev-data`;
- backup directories under `/srv/greendev-data/backups`;
- rsync snapshot backups with hard-link incrementals;
- SHA256 integrity manifests;
- restore tests to an alternate location;
- a systemd backup service and timer;
- optional NFS network storage.

## Relevant files

```text
scripts/week5/
├── setup_week5_tools.sh
├── detect_storage_candidates.sh
├── setup_storage_disk.sh
├── setup_backup_directories.sh
├── run_backup.sh
├── verify_backup_integrity.sh
├── test_restore.sh
├── cleanup_old_backups.sh
├── setup_backup_service.sh
├── backup_status.sh
├── setup_nfs_server_optional.sh
└── verify_week5_setup.sh

systemd/week5/
├── gsx-week5-backup.service
├── gsx-week5-backup.timer
└── README-week5-systemd.md

docs/
├── week5.md
├── storage-layout-week5.md
├── backup-strategy-week5.md
├── backup-restore-week5.md
├── nfs-optional-week5.md
├── disaster-recovery-runbook-week5.md
├── troubleshooting-week5.md
├── testing-evidence-week5.md
└── week5-reflection.md
```

## Storage root

The Week 5 storage root is:

```text
/srv/greendev-data
```

Recommended layout:

```text
/srv/greendev-data/
├── backups/
│   └── snapshots/
│       ├── 20260608-230000/
│       └── latest -> 20260608-230000
├── restore-tests/
└── shared/
```

## Setup summary

Detect disks:

```bash
cd scripts/week5
./detect_storage_candidates.sh
```

Configure the new disk:

```bash
sudo ./setup_storage_disk.sh /dev/sdb /srv/greendev-data
```

Prepare backup directories:

```bash
sudo ./setup_backup_directories.sh /srv/greendev-data
```

Run backup and verify:

```bash
sudo ./run_backup.sh /srv/greendev-data
sudo ./verify_backup_integrity.sh /srv/greendev-data/backups/snapshots/latest
```

Test restore:

```bash
sudo ./test_restore.sh /srv/greendev-data
```

Install automated backup service and timer:

```bash
sudo ./setup_backup_service.sh /srv/greendev-data
sudo systemctl start gsx-week5-backup.service
```

Verify everything:

```bash
sudo ./verify_week5_setup.sh /srv/greendev-data
```

## Main verification

Expected result:

```text
[+] Week 5 verification passed.
```

## Optional NFS

The optional networked storage part exports:

```text
/srv/greendev-data/shared
```

to another VM using NFS. This is documented in:

```text
docs/nfs-optional-week5.md
```

## Design summary

The storage and backup design separates application/team data from the root filesystem. Backups are stored on the new disk and verified using checksums. Restore tests are performed in an alternate location to prove that backups are usable without overwriting the live system.

