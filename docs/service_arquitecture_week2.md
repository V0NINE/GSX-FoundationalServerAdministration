# Week 2 Service Architecture

## Overview

The Week 2 architecture introduces managed services and scheduled automation using `systemd`.

```text
+-----------------------+
| Debian VM             |
|                       |
|  +-----------------+  |
|  | nginx.service   |  |
|  | Web server      |  |
|  +--------+--------+  |
|           |           |
|           v           |
|  http://localhost     |
|                       |
|  +-----------------+  |
|  | gsx-backup.timer|  |
|  +--------+--------+  |
|           | triggers  |
|           v           |
|  +-----------------+  |
|  | gsx-backup     |  |
|  | .service       |  |
|  +--------+--------+  |
|           | runs      |
|           v           |
|  backup_admin_data.sh |
|           |           |
|           v           |
|  /var/backups/gsx     |
|                       |
|  Logs: journald       |
+-----------------------+
```

## Nginx service

Nginx is installed from Debian packages and managed through the default `nginx.service`.

Commands:

```bash
sudo systemctl enable nginx
sudo systemctl restart nginx
systemctl status nginx
```

The service is configured to restart on failure through a drop-in override:

```text
/etc/systemd/system/nginx.service.d/override.conf
```

Content:

```ini
[Service]
Restart=on-failure
RestartSec=5s
```

## Why use a systemd override?

Replacing the entire Debian-provided Nginx unit file would be risky. The distribution package already provides a tested service definition. A drop-in override changes only the behaviour we need, while preserving the rest of the package defaults.

This is easier to maintain and less likely to break during package updates.

## Backup service

The backup service is defined as:

```text
/etc/systemd/system/gsx-backup.service
```

It runs the Week 1 backup script from:

```text
/opt/gsx-admin/scripts/backup_admin_data.sh
```

The service is `Type=oneshot` because it performs one task and exits.

Important properties:

```ini
[Service]
Type=oneshot
ExecStart=/opt/gsx-admin/scripts/backup_admin_data.sh
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=7
```

The `Nice` and I/O scheduling values reduce the priority of the backup task so it is less likely to interfere with interactive work.

## Backup timer

The backup timer is defined as:

```text
/etc/systemd/system/gsx-backup.timer
```

It schedules the backup service:

```ini
[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=10min
Unit=gsx-backup.service
```

### Why use a timer instead of cron?

A `systemd` timer integrates directly with service state and logs. This makes it easy to inspect the backup using:

```bash
systemctl status gsx-backup.timer
systemctl status gsx-backup.service
journalctl -u gsx-backup.service
```

`Persistent=true` also means that if the VM was powered off when the timer should have run, systemd can run the missed job after boot.

## Logging

Both Nginx and the backup service are observable through `journalctl`.

Useful commands:

```bash
journalctl -u nginx
journalctl -u nginx --since "1 hour ago"
journalctl -u gsx-backup.service
journalctl -u gsx-backup.service --since "today"
```

## Failure behaviour

If Nginx fails, `systemd` should restart it according to the override policy.

If the backup fails, `gsx-backup.service` enters a failed state, and the error can be inspected with:

```bash
systemctl status gsx-backup.service
journalctl -u gsx-backup.service
```

This behaviour is important because failures should not be silent.
