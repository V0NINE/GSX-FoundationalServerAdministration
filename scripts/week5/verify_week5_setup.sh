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

# verify_week5_setup.sh - Verify Week 5 storage, backup and restore setup
#
# USAGE:
#   sudo ./verify_week5_setup.sh [/srv/greendev-data]

require_root

DATA_ROOT="${1:-/srv/greendev-data}"
FAILED=0

pass() { output_message SUCCESS "$1"; }
fail() { output_message ERROR "$1"; FAILED=1; }

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        pass "$description"
    else
        fail "$description"
    fi
}

check "$DATA_ROOT exists" test -d "$DATA_ROOT"
check "$DATA_ROOT is mounted" mountpoint -q "$DATA_ROOT"
check "$DATA_ROOT appears in /etc/fstab" grep -q " $DATA_ROOT " /etc/fstab
check "Backup snapshot directory exists" test -d "$DATA_ROOT/backups/snapshots"
check "Latest backup symlink exists" test -e "$DATA_ROOT/backups/snapshots/latest"
check "Latest backup manifest exists" test -f "$DATA_ROOT/backups/snapshots/latest/SHA256SUMS"
check "Latest backup integrity passes" "$SCRIPT_DIR/verify_backup_integrity.sh" "$DATA_ROOT/backups/snapshots/latest"
check "Week 5 backup service exists" test -f /etc/systemd/system/gsx-week5-backup.service
check "Week 5 backup timer exists" test -f /etc/systemd/system/gsx-week5-backup.timer
check "Week 5 backup timer is enabled" systemctl is-enabled -q gsx-week5-backup.timer
check "Week 5 backup timer is active" systemctl is-active -q gsx-week5-backup.timer
check "Restore test can run" "$SCRIPT_DIR/test_restore.sh" "$DATA_ROOT"

if [ "$FAILED" -eq 0 ]; then
    output_message SUCCESS "Week 5 verification passed."
else
    output_message ERROR "Week 5 verification failed."
fi

exit "$FAILED"
