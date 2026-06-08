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

# verify_backup_integrity.sh - Verify SHA256 manifest for a Week 5 backup
#
# USAGE:
#   sudo ./verify_backup_integrity.sh [snapshot_path]
#
# If no path is provided, verifies latest snapshot.

require_root

DATA_ROOT="/srv/greendev-data"
SNAPSHOT="${1:-$DATA_ROOT/backups/snapshots/latest}"

if [ ! -d "$SNAPSHOT" ]; then
    output_message ERROR "Snapshot directory does not exist: $SNAPSHOT"
    exit 1
fi

if [ ! -f "$SNAPSHOT/SHA256SUMS" ]; then
    output_message ERROR "Manifest not found: $SNAPSHOT/SHA256SUMS"
    exit 1
fi

output_message INFO "Verifying backup integrity for $SNAPSHOT"
(
    cd "$SNAPSHOT"
    sha256sum -c SHA256SUMS
)

output_message SUCCESS "Backup integrity verification passed."
