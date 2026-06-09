# Operational Runbooks

## Purpose

This document provides step-by-step procedures for common sysadmin tasks.

## Runbook: restart Nginx

### When to use

Use when the web service is not responding or after configuration changes.

### Commands

```bash
sudo nginx -t
sudo systemctl restart nginx
systemctl status nginx --no-pager
curl -I http://localhost
journalctl -u nginx --since "10 minutes ago" --no-pager
```

### Expected result

- `nginx -t` passes;
- service is active;
- `curl` returns an HTTP response.

## Runbook: check service logs

### Commands

```bash
journalctl -u <service> --since "1 hour ago" --no-pager
```

Examples:

```bash
journalctl -u nginx --since "1 hour ago" --no-pager
journalctl -u gsx-week5-backup.service --since "today" --no-pager
```

## Runbook: add a new developer

Example user: `dev5`.

```bash
cd scripts/week4
sudo ./add_developer.sh dev5
id dev5
ls -ld /home/dev5
```

Expected:

- user exists;
- user belongs to `greendevcorp`;
- home directory is private.

If SSH login is required, add the public key to:

```text
/home/dev5/.ssh/authorized_keys
```

with permissions:

```bash
sudo chmod 700 /home/dev5/.ssh
sudo chmod 600 /home/dev5/.ssh/authorized_keys
```

## Runbook: offboard a developer

Example user: `dev5`.

```bash
sudo passwd -l dev5
sudo pkill -KILL -u dev5 || true
sudo gpasswd -d dev5 greendevcorp
sudo mv /home/dev5/.ssh/authorized_keys /home/dev5/.ssh/authorized_keys.disabled
```

Archive home directory if required:

```bash
sudo tar -czf /var/backups/gsx/dev5-home-archive.tar.gz /home/dev5
```

Do not delete user data until retention requirements are confirmed.

## Runbook: debug a file access issue

Example:

```bash
id dev2
ls -l /path/to/file
ls -ld /path/to
getfacl /path/to/file
getfacl /path/to
```

Check:

- user group membership;
- owner/group/mode;
- ACL entries;
- ACL mask;
- parent directory execute permission;
- whether the user needs a new login session.

## Runbook: check process resource usage

```bash
cd scripts/week3
./list_top_processes.sh cpu 10
./list_top_processes.sh mem 10
./show_process_tree.sh
./process_metrics.sh <PID>
```

If the process belongs to a service:

```bash
systemctl status <service> --no-pager
journalctl -u <service> --since "1 hour ago" --no-pager
```

## Runbook: stop a misbehaving process

Graceful stop first:

```bash
kill -TERM <PID>
```

If it does not stop:

```bash
kill -KILL <PID>
```

For systemd services:

```bash
sudo systemctl stop <service>
sudo systemctl kill <service>
```

Use `SIGKILL` only as a last resort.

## Runbook: run manual backup

```bash
cd scripts/week5
sudo ./run_backup.sh /srv/greendev-data
sudo ./verify_backup_integrity.sh /srv/greendev-data/backups/snapshots/latest
```

## Runbook: test backup restore

```bash
cd scripts/week5
sudo ./test_restore.sh /srv/greendev-data
ls -lh /srv/greendev-data/restore-tests
```

Expected:

- restore test passes;
- restored files appear in a timestamped directory.

## Runbook: check backup automation

```bash
systemctl status gsx-week5-backup.timer --no-pager
systemctl list-timers --all | grep gsx-week5-backup
journalctl -u gsx-week5-backup.service --since "today" --no-pager
```

## Runbook: disk usage check

```bash
df -h
df -h /srv/greendev-data
du -sh /srv/greendev-data/backups/snapshots/*
```

If backups are consuming too much space:

```bash
cd scripts/week5
sudo ./cleanup_old_backups.sh 7 /srv/greendev-data
```

## Runbook: verify the whole system

```bash
sudo ./scripts/week2/verify_week2_setup.sh
sudo ./scripts/week3/verify_week3_setup.sh
sudo ./scripts/week4/verify_week4_setup.sh
sudo ./scripts/week5/verify_week5_setup.sh /srv/greendev-data
```
