# Week 5 Backup and Restore Procedures

## Run a manual backup

From the repository:

```bash
cd scripts/week5
sudo ./run_backup.sh /srv/greendev-data
```

Expected result:

```text
[+] Backup snapshot completed
```

Snapshots are stored in:

```text
/srv/greendev-data/backups/snapshots
```

Check:

```bash
ls -lh /srv/greendev-data/backups/snapshots
```

## Verify backup integrity

```bash
sudo ./verify_backup_integrity.sh /srv/greendev-data/backups/snapshots/latest
```

Expected result:

```text
[+] Backup integrity verification passed.
```

## Run a restore test

```bash
sudo ./test_restore.sh /srv/greendev-data
```

This restores the latest snapshot to:

```text
/srv/greendev-data/restore-tests/restore-<timestamp>
```

It does not overwrite live files.

Expected result:

```text
[+] Restore test passed
```

## Inspect restored files

```bash
ls -lh /srv/greendev-data/restore-tests
find /srv/greendev-data/restore-tests -maxdepth 4 -type f | head
```

## Restore a single file manually

Example: restore a file from the latest snapshot.

```bash
sudo cp -a /srv/greendev-data/backups/snapshots/latest/home/greendevcorp/done.log /tmp/done.log.restored
```

Then inspect:

```bash
ls -l /tmp/done.log.restored
```

## Restore a directory manually

Example:

```bash
sudo rsync -aHAX --numeric-ids   /srv/greendev-data/backups/snapshots/latest/home/greendevcorp/   /tmp/greendevcorp-restore/
```

## Full recovery idea

For a full recovery after reinstall:

1. reinstall Debian VM;
2. install Git and clone the repository;
3. run Week 1 setup;
4. run Week 4 setup if users/groups are needed;
5. mount the Week 5 backup disk;
6. restore data from latest snapshot;
7. verify ownership and permissions;
8. restart services;
9. run verification scripts.

## Important safety rule

Never restore directly over live paths without first testing in an alternate location.

Safe restore test:

```text
/srv/greendev-data/restore-tests
```

Risky direct restore:

```text
/home/greendevcorp
/etc/ssh
/etc/sudoers.d
```

Direct restore should only be done during a planned recovery procedure.

## Logs

Backup logs:

```bash
journalctl -u gsx-week5-backup.service --since "today" --no-pager
```

Custom log files:

```text
/var/log/gsx/week5-backup.log
/var/log/gsx/week5-restore-test.log
```

## Status script

```bash
./backup_status.sh /srv/greendev-data
```
