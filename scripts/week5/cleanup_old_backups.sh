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

# cleanup_old_backups.sh - Keep only the newest N Week 5 snapshots
#
# USAGE:
#   sudo ./cleanup_old_backups.sh [keep_count] [/srv/greendev-data]
#
# EXAMPLE:
#   sudo ./cleanup_old_backups.sh 7

require_root

KEEP_COUNT="${1:-7}"
DATA_ROOT="${2:-/srv/greendev-data}"
SNAPSHOT_ROOT="$DATA_ROOT/backups/snapshots"

if ! [[ "$KEEP_COUNT" =~ ^[0-9]+$ ]] || [ "$KEEP_COUNT" -lt 1 ]; then
    output_message ERROR "keep_count must be a positive integer."
    exit 1
fi

if [ ! -d "$SNAPSHOT_ROOT" ]; then
    output_message ERROR "Snapshot root does not exist: $SNAPSHOT_ROOT"
    exit 1
fi

output_message INFO "Keeping newest $KEEP_COUNT snapshots in $SNAPSHOT_ROOT"

mapfile -t snapshots < <(find "$SNAPSHOT_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -r)

count=0
for snap in "${snapshots[@]}"; do
    count=$((count + 1))
    if [ "$count" -gt "$KEEP_COUNT" ]; then
        output_message WARNING "Removing old snapshot: $snap"
        rm -rf "$SNAPSHOT_ROOT/$snap"
    fi
done

# Refresh latest symlink to newest remaining snapshot.
newest="$(find "$SNAPSHOT_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -r | head -n 1 || true)"
if [ -n "$newest" ]; then
    ln -sfn "$SNAPSHOT_ROOT/$newest" "$SNAPSHOT_ROOT/latest"
fi

output_message SUCCESS "Backup cleanup completed."
