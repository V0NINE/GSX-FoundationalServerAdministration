# Week 2 Observability Guide

## Purpose

Observability means being able to understand what the system is doing and diagnose failures. In Week 2, observability is based on standard Debian tools:

- `systemctl` for service state.
- `journalctl` for logs.
- custom helper scripts for common checks.

## Service status

Check all Week 2 services:

```bash
./check_services.sh
```

Or manually:

```bash
systemctl status nginx --no-pager
systemctl status gsx-backup.timer --no-pager
systemctl status gsx-backup.service --no-pager
```

## Nginx checks

Check whether Nginx is enabled and running:

```bash
systemctl is-enabled nginx
systemctl is-active nginx
```

Check whether it responds locally:

```bash
curl -I http://localhost
```

Expected result: an HTTP response, normally `HTTP/1.1 200 OK`.

## Backup checks

Check the timer:

```bash
systemctl status gsx-backup.timer --no-pager
systemctl list-timers --all | grep gsx-backup
```

Check the last service execution:

```bash
systemctl status gsx-backup.service --no-pager
journalctl -u gsx-backup.service --since "today" --no-pager
```

Check latest backup archive:

```bash
ls -lh /var/backups/gsx
tar -tzf /var/backups/gsx/latest-week1-admin.tar.gz >/dev/null
```

Or use:

```bash
./check_backup_status.sh
```

## Logs

Show recent Nginx logs:

```bash
./show_service_logs.sh nginx "10 minutes ago"
```

Show today's backup logs:

```bash
./show_service_logs.sh gsx-backup.service "today"
```

Manual equivalent:

```bash
journalctl -u nginx --since "10 minutes ago" --no-pager
journalctl -u gsx-backup.service --since "today" --no-pager
```

## Testing failure and recovery

To demonstrate Nginx failure recovery:

```bash
sudo ./test_nginx_recovery.sh
```

This intentionally kills Nginx processes and waits for systemd to restart the service.

Evidence to collect:

```bash
systemctl status nginx --no-pager
journalctl -u nginx --since "2 minutes ago" --no-pager
```

## Log retention

To prevent logs from consuming unlimited disk space, journald is configured in:

```text
/etc/systemd/journald.conf.d/gsx-retention.conf
```

Current policy:

```ini
[Journal]
SystemMaxUse=200M
MaxRetentionSec=7day
Compress=yes
```

Check journal disk usage:

```bash
journalctl --disk-usage
```

## What to do when something fails

General approach:

1. Check status with `systemctl status <unit>`.
2. Read logs with `journalctl -u <unit>`.
3. Identify the failing command or missing dependency.
4. Fix the cause.
5. Restart or re-run the service.
6. Verify again.
7. Document the incident and the fix.

Example:

```bash
systemctl status gsx-backup.service --no-pager
journalctl -u gsx-backup.service -n 50 --no-pager
sudo systemctl start gsx-backup.service
```
