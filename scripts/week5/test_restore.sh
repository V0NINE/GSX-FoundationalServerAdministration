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

# test_restore.sh - Restore latest backup to alternate location and verify it
#
# USAGE:
#   sudo ./test_restore.sh [/srv/greendev-data]
#
# This script does not overwrite production files. It restores into:
#   /srv/greendev-data/restore-tests/<timestamp>

require_root

DATA_ROOT="${1:-/srv/greendev-data}"
SNAPSHOT="$DATA_ROOT/backups/snapshots/latest"
RESTORE_ROOT="$DATA_ROOT/restore-tests"
RESTORE_DIR="$RESTORE_ROOT/restore-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/var/log/gsx/week5-restore-test.log"

if [ ! -d "$SNAPSHOT" ]; then
    output_message ERROR "Latest snapshot does not exist: $SNAPSHOT"
    exit 1
fi

mkdir -p "$RESTORE_DIR" "$(dirname "$LOG_FILE")"

output_message INFO "Restoring $SNAPSHOT to $RESTORE_DIR"
rsync -aHAX --numeric-ids "$SNAPSHOT/" "$RESTORE_DIR/"

output_message INFO "Verifying restored manifest..."
(
    cd "$RESTORE_DIR"
    sha256sum -c SHA256SUMS >/dev/null
)

# Basic content checks
test -d "$RESTORE_DIR/home/greendevcorp"
test -d "$RESTORE_DIR/opt/gsx-admin"
test -d "$RESTORE_DIR/etc/ssh"

echo "$(date --iso-8601=seconds) SUCCESS $RESTORE_DIR" >> "$LOG_FILE"

output_message SUCCESS "Restore test passed: $RESTORE_DIR"
du -sh "$RESTORE_DIR" 2>/dev/null || true
