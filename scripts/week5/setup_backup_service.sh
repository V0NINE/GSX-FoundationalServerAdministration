#!/usr/bin/env bash
# setup_backup_service.sh - Install Week 5 backup service and timer
#
# USAGE:
#   sudo ./setup_backup_service.sh [/srv/greendev-data]
#
# Creates:
#   /etc/systemd/system/gsx-week5-backup.service
#   /etc/systemd/system/gsx-week5-backup.timer
#
# It can use templates from systemd/week5 if they exist. Otherwise, it generates
# equivalent unit files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../script_message.sh" ]; then
    source "$SCRIPT_DIR/../script_message.sh"
else
    output_message() {
        local level="${1:-INFO}"
        shift || true
        echo "[$level] $*"
    }
    require_root() {
        if [ "${EUID}" -ne 0 ]; then
            echo "[ERROR] This script must be run as root. Use sudo." >&2
            exit 1
        fi
    }
fi

require_root

DATA_ROOT="${1:-/srv/greendev-data}"
INSTALL_DIR="/opt/gsx-admin/scripts/week5"
SERVICE_FILE="/etc/systemd/system/gsx-week5-backup.service"
TIMER_FILE="/etc/systemd/system/gsx-week5-backup.timer"

# Repo root: scripts/week5 -> ../..
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SERVICE_TEMPLATE="$REPO_ROOT/systemd/week5/gsx-week5-backup.service"
TIMER_TEMPLATE="$REPO_ROOT/systemd/week5/gsx-week5-backup.timer"

mkdir -p "$INSTALL_DIR" /opt/gsx-admin/scripts

if [ -f "$SCRIPT_DIR/../script_message.sh" ]; then
    install -m 0755 "$SCRIPT_DIR/../script_message.sh" /opt/gsx-admin/scripts/script_message.sh
fi

for script in run_backup.sh verify_backup_integrity.sh test_restore.sh cleanup_old_backups.sh setup_backup_directories.sh; do
    if [ ! -f "$SCRIPT_DIR/$script" ]; then
        output_message ERROR "Missing required script: $SCRIPT_DIR/$script"
        exit 1
    fi
    install -m 0755 "$SCRIPT_DIR/$script" "$INSTALL_DIR/$script"
done

if [ -f "$SERVICE_TEMPLATE" ]; then
    install -m 0644 "$SERVICE_TEMPLATE" "$SERVICE_FILE"
    # Replace default data root if a custom path was passed.
    if [ "$DATA_ROOT" != "/srv/greendev-data" ]; then
        sed -i "s#/srv/greendev-data#$DATA_ROOT#g" "$SERVICE_FILE"
    fi
else
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=GSX Week 5 rsync snapshot backup
RequiresMountsFor=$DATA_ROOT
After=local-fs.target

[Service]
Type=oneshot
ExecStart=$INSTALL_DIR/run_backup.sh $DATA_ROOT
ExecStartPost=$INSTALL_DIR/verify_backup_integrity.sh $DATA_ROOT/backups/snapshots/latest
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=7
EOF
fi

if [ -f "$TIMER_TEMPLATE" ]; then
    install -m 0644 "$TIMER_TEMPLATE" "$TIMER_FILE"
else
    cat > "$TIMER_FILE" <<'EOF'
[Unit]
Description=Run GSX Week 5 backup daily

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=15min
Unit=gsx-week5-backup.service

[Install]
WantedBy=timers.target
EOF
fi

chmod 0644 "$SERVICE_FILE" "$TIMER_FILE"

systemctl daemon-reload
systemctl enable --now gsx-week5-backup.timer

output_message SUCCESS "Week 5 backup service and timer installed."
output_message INFO "Service: $SERVICE_FILE"
output_message INFO "Timer:   $TIMER_FILE"
systemctl list-timers --all | grep -E 'gsx-week5-backup|NEXT' || true
