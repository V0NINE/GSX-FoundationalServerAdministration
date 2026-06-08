#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/var/backups/gsx"
LATEST_LINK="$BACKUP_DIR/latest-week1-admin.tar.gz"

echo "== Timer status =="
systemctl status gsx-backup.timer --no-pager || true

echo
echo "== Last backup logs =="
journalctl -u gsx-backup.service -n 40 --no-pager || true

echo
echo "== Backup files =="
if [ -d "$BACKUP_DIR" ]; then
    ls -lh "$BACKUP_DIR" || true
else
    echo "$BACKUP_DIR does not exist"
fi

echo
echo "== Latest backup integrity =="
if [ -e "$LATEST_LINK" ]; then
    tar -tzf "$LATEST_LINK" >/dev/null
    echo "OK: latest backup archive is readable."
else
    echo "ERROR: $LATEST_LINK does not exist." >&2
    exit 1
fi
