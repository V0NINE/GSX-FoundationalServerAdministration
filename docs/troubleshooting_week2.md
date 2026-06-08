# Week 2 Troubleshooting Guide

## Nginx is not active

Check:

```bash
systemctl status nginx --no-pager
journalctl -u nginx -n 50 --no-pager
```

Try restarting:

```bash
sudo systemctl restart nginx
```

If it still fails, test the Nginx configuration:

```bash
sudo nginx -t
```

## Nginx does not respond on localhost

Check whether it is listening:

```bash
sudo ss -tlnp | grep ':80'
```

Check service state:

```bash
systemctl status nginx --no-pager
```

Check local HTTP response:

```bash
curl -I http://localhost
```

Possible causes:

- Nginx service is stopped.
- Port 80 is not open/listening.
- Configuration syntax error.
- Another service is using port 80.

## Nginx does not restart after failure

Check whether the override exists:

```bash
cat /etc/systemd/system/nginx.service.d/override.conf
```

Expected:

```ini
[Service]
Restart=on-failure
RestartSec=5s
```

Reload systemd and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart nginx
```

Test again:

```bash
sudo ./test_nginx_recovery.sh
```

## Backup service fails

Check status and logs:

```bash
systemctl status gsx-backup.service --no-pager
journalctl -u gsx-backup.service -n 50 --no-pager
```

Common causes:

- `/opt/gsx-admin/scripts/backup_admin_data.sh` is missing.
- `/opt/gsx-admin/scripts/script_message.sh` is missing.
- The backup script is not executable.
- `/var/backups/gsx` does not exist or has wrong permissions.
- The backup script fails because one of its source paths is invalid.

Fix common script-copy issue:

```bash
sudo cp scripts/backup_admin_data.sh /opt/gsx-admin/scripts/
sudo cp scripts/script_message.sh /opt/gsx-admin/scripts/
sudo chmod 755 /opt/gsx-admin/scripts/backup_admin_data.sh
sudo chmod 755 /opt/gsx-admin/scripts/script_message.sh
sudo systemctl start gsx-backup.service
```

## Backup timer is not active

Check:

```bash
systemctl status gsx-backup.timer --no-pager
systemctl list-timers --all | grep gsx-backup
```

Enable it:

```bash
sudo systemctl enable --now gsx-backup.timer
```

If unit files were changed:

```bash
sudo systemctl daemon-reload
sudo systemctl restart gsx-backup.timer
```

## Latest backup does not exist

Run the service manually:

```bash
sudo systemctl start gsx-backup.service
```

Then check:

```bash
ls -lh /var/backups/gsx
tar -tzf /var/backups/gsx/latest-week1-admin.tar.gz >/dev/null
```

If it fails, inspect logs:

```bash
journalctl -u gsx-backup.service -n 50 --no-pager
```

## journald retention file missing

Re-run:

```bash
sudo ./setup_journald_retention.sh
```

Check:

```bash
cat /etc/systemd/journald.conf.d/gsx-retention.conf
journalctl --disk-usage
```

## verify_week2_setup.sh fails

Run:

```bash
sudo ./verify_week2_setup.sh
```

For each failed item, check the corresponding unit or file.

Typical fixes:

```bash
sudo ./setup_nginx.sh
sudo ./setup_backup_timer.sh
sudo ./setup_journald_retention.sh
sudo ./verify_week2_setup.sh
```

## Useful diagnostic commands

```bash
systemctl --failed
systemctl list-units --type=service
systemctl list-timers --all
journalctl -p warning --since "1 hour ago" --no-pager
journalctl -u nginx --since "1 hour ago" --no-pager
journalctl -u gsx-backup.service --since "today" --no-pager
```
