# Week 2 — Services, Observability and Automation

## Goal

The goal of Week 2 is to move from manual administration to reliable service management. The server must run services through `systemd`, expose useful logs through `journald`, and execute backups automatically through a scheduled timer.

This week focuses on three ideas:

1. Services should start automatically and recover from failures.
2. Failures should be observable through standard tools.
3. Repetitive tasks, such as backups, should be automated.

## Implemented components

The Week 2 implementation includes:

- Nginx installed as the example web service.
- Nginx enabled at boot.
- A `systemd` override for Nginx restart policy.
- A custom `gsx-backup.service` unit.
- A custom `gsx-backup.timer` unit.
- A journald retention configuration.
- Scripts for service checks, backup checks, log inspection and recovery testing.
- Verification script for the Week 2 baseline.

## Relevant files

```text
scripts/
├── setup_nginx.sh
├── setup_backup_timer.sh
├── setup_journald_retention.sh
├── check_services.sh
├── show_service_logs.sh
├── check_backup_status.sh
├── test_nginx_recovery.sh
├── verify_week2_setup.sh
└── install_week2.sh

systemd/
├── nginx-override.conf
├── gsx-backup.service
├── gsx-backup.timer
└── journald-gsx-retention.conf

docs/
├── week2.md
├── service-architecture-week2.md
├── observability-week2.md
├── troubleshooting-week2.md
└── testing-evidence-week2.md
```

## Setup procedure

Run the Week 2 installation from the repository:

```bash
chmod +x scripts/*.sh
cd scripts
sudo ./install_week2.sh
```

The installer runs:

```text
setup_nginx.sh
setup_backup_timer.sh
setup_journald_retention.sh
verify_week2_setup.sh
```

## Manual verification

After installation, run:

```bash
./check_services.sh
./check_backup_status.sh
sudo ./test_nginx_recovery.sh
sudo ./verify_week2_setup.sh
```

Expected result:

- Nginx is installed, enabled and active.
- Nginx responds on `http://localhost`.
- `gsx-backup.timer` is enabled and active.
- `gsx-backup.service` can run successfully.
- The latest backup archive exists and is readable.
- Journald retention configuration exists.
- Week 2 verification passes.

## Commands used for evidence

```bash
systemctl status nginx --no-pager
systemctl is-enabled nginx
curl -I http://localhost

systemctl status gsx-backup.timer --no-pager
systemctl list-timers --all | grep gsx-backup
journalctl -u gsx-backup.service --since "today" --no-pager

journalctl -u nginx --since "10 minutes ago" --no-pager
cat /etc/systemd/journald.conf.d/gsx-retention.conf
journalctl --disk-usage

sudo ./verify_week2_setup.sh
```

## Design summary

Nginx is managed with the package-provided `systemd` service instead of replacing it with a fully custom service. This is safer because Debian already provides a tested unit file.

The custom backup integration uses a `oneshot` service because a backup is a task that starts, performs work and exits. The timer is responsible for scheduling.

Observability is based on `systemctl` and `journalctl`, because they are standard tools available on modern Debian systems using `systemd`.

