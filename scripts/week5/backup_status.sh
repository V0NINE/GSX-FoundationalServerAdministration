#!/usr/bin/env bash
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

# backup_status.sh - Show Week 5 backup status
#
# USAGE:
#   ./backup_status.sh [/srv/greendev-data]

DATA_ROOT="${1:-/srv/greendev-data}"
SNAPSHOT_ROOT="$DATA_ROOT/backups/snapshots"

echo "== Storage mount =="
findmnt "$DATA_ROOT" || true

echo
echo "== Disk usage =="
df -h "$DATA_ROOT" 2>/dev/null || true

echo
echo "== Backup timer =="
systemctl status gsx-week5-backup.timer --no-pager || true

echo
echo "== Last backup service logs =="
journalctl -u gsx-week5-backup.service -n 60 --no-pager || true

echo
echo "== Snapshots =="
if [ -d "$SNAPSHOT_ROOT" ]; then
    ls -lh "$SNAPSHOT_ROOT" || true
else
    echo "$SNAPSHOT_ROOT does not exist"
fi

echo
echo "== Latest snapshot size =="
if [ -e "$SNAPSHOT_ROOT/latest" ]; then
    du -sh "$SNAPSHOT_ROOT/latest" 2>/dev/null || true
else
    echo "No latest snapshot."
fi
