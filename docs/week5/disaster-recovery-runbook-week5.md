# Week 5 Disaster Recovery Runbook

## Purpose

This runbook explains how to recover the GreenDevCorp server data from Week 5 backups.

## Scenario

The original server has failed or data has been lost. A new Debian VM must be prepared and data must be restored from backup.

## Assumptions

- The backup disk or backup snapshot is still available.
- The Git repository is available.
- The latest backup is located under `/srv/greendev-data/backups/snapshots/latest`.

## Recovery steps

### 1. Install a fresh Debian VM

Install Debian and log in locally.

### 2. Install basic tools

```bash
sudo apt update
sudo apt install -y git rsync acl attr
```

### 3. Clone repository

```bash
git clone <REPOSITORY_URL>
cd GSX-FoundationalServerAdministration
```

### 4. Reapply baseline configuration

Run previous week setup scripts as needed:

```bash
cd scripts
sudo ./install_week1.sh --ssh-mode bootstrap --sudo-user gsx
```

Then apply Week 4 users/groups if needed:

```bash
cd week4
sudo ./install_week4.sh
```

### 5. Attach and mount backup disk

If the disk is attached but not mounted:

```bash
lsblk -f
sudo mkdir -p /srv/greendev-data
sudo mount <BACKUP_PARTITION> /srv/greendev-data
```

If `/etc/fstab` is known, restore or recreate it using UUID.

### 6. Verify backup integrity

```bash
cd scripts/week5
sudo ./verify_backup_integrity.sh /srv/greendev-data/backups/snapshots/latest
```

Do not restore from a backup that fails integrity verification unless there is no alternative.

### 7. Test restore first

```bash
sudo ./test_restore.sh /srv/greendev-data
```

### 8. Restore required data

Example restore for team data:

```bash
sudo rsync -aHAX --numeric-ids   /srv/greendev-data/backups/snapshots/latest/home/greendevcorp/   /home/greendevcorp/
```

Example restore for admin scripts:

```bash
sudo rsync -aHAX --numeric-ids   /srv/greendev-data/backups/snapshots/latest/opt/gsx-admin/   /opt/gsx-admin/
```

Be careful when restoring `/etc` files. Review them before overwriting live configuration.

### 9. Verify permissions

```bash
ls -ld /home/greendevcorp
ls -l /home/greendevcorp/done.log
getfacl /home/greendevcorp/shared
```

Run relevant verification scripts:

```bash
cd scripts/week4
sudo ./verify_week4_setup.sh

cd ../week5
sudo ./verify_week5_setup.sh /srv/greendev-data
```

### 10. Restart services

```bash
sudo systemctl daemon-reload
sudo systemctl restart ssh
sudo systemctl restart nginx
sudo systemctl restart gsx-week5-backup.timer
```

## RTO

Estimated recovery time for the lab:

```text
15–30 minutes
```

depending on VM setup and data size.

## RPO

With daily backups:

```text
up to 24 hours of data loss
```

## Escalation

Escalate if:

- backup integrity verification fails;
- backup disk cannot be mounted;
- restored permissions are inconsistent;
- critical services fail after restore;
- multiple backup snapshots are corrupted.
