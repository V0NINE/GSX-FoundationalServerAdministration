#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

require_root

ADMIN_SCRIPT_DIR="/opt/gsx-admin/scripts"
BACKUP_SCRIPT_SRC="$SCRIPT_DIR/../week1/backup_admin_data.sh"
BACKUP_SCRIPT_DST="$ADMIN_SCRIPT_DIR/backup_admin_data.sh"

SERVICE_FILE="/etc/systemd/system/gsx-backup.service"
TIMER_FILE="/etc/systemd/system/gsx-backup.timer"

mkdir -p "$ADMIN_SCRIPT_DIR"

install -m 0755 "$SCRIPT_DIR/../script_message.sh" "$ADMIN_SCRIPT_DIR/script_message.sh"

if [ -f "$BACKUP_SCRIPT_SRC" ]; then
    install -m 0755 "$BACKUP_SCRIPT_SRC" "$BACKUP_SCRIPT_DST"
    output_message SUCCESS "Installed backup script to $BACKUP_SCRIPT_DST."
elif [ -x "$BACKUP_SCRIPT_DST" ]; then
    output_message WARNING "Using existing backup script at $BACKUP_SCRIPT_DST."
else
    output_message ERROR "backup_admin_data.sh not found in $SCRIPT_DIR or $ADMIN_SCRIPT_DIR."
    exit 1
fi

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=GSX administrative backup
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=$BACKUP_SCRIPT_DST
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=7
EOF

cat > "$TIMER_FILE" <<'EOF'
[Unit]
Description=Run GSX administrative backup daily

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=10min
Unit=gsx-backup.service

[Install]
WantedBy=timers.target
EOF

chmod 0644 "$SERVICE_FILE" "$TIMER_FILE"

systemctl daemon-reload
systemctl enable --now gsx-backup.timer

output_message INFO "Running one manual backup through systemd..."
systemctl start gsx-backup.service

if systemctl is-active -q gsx-backup.timer; then
    output_message SUCCESS "gsx-backup.timer is active."
else
    output_message ERROR "gsx-backup.timer is not active."
    exit 1
fi

if systemctl --quiet is-failed gsx-backup.service; then
    output_message ERROR "gsx-backup.service failed."
    journalctl -u gsx-backup.service -n 50 --no-pager || true
    exit 1
fi

output_message SUCCESS "Backup service and timer installed."
systemctl list-timers --all | grep -E 'gsx-backup|NEXT' || true

