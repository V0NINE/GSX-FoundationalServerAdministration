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

# setup_backup_directories.sh - Create Week 5 backup directories
#
# USAGE:
#   sudo ./setup_backup_directories.sh [/srv/greendev-data]

require_root

DATA_ROOT="${1:-/srv/greendev-data}"
BACKUP_ROOT="$DATA_ROOT/backups"
SNAPSHOT_ROOT="$BACKUP_ROOT/snapshots"
LOG_DIR="/var/log/gsx"

mkdir -p "$SNAPSHOT_ROOT" "$DATA_ROOT/restore-tests" "$LOG_DIR"
chown root:root "$BACKUP_ROOT" "$SNAPSHOT_ROOT" "$DATA_ROOT/restore-tests" "$LOG_DIR"
chmod 0750 "$BACKUP_ROOT" "$SNAPSHOT_ROOT"
chmod 0755 "$DATA_ROOT/restore-tests"
chmod 0755 "$LOG_DIR"

output_message SUCCESS "Week 5 backup directories are ready."
ls -ld "$BACKUP_ROOT" "$SNAPSHOT_ROOT" "$DATA_ROOT/restore-tests" "$LOG_DIR"
