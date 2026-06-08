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

# run_backup.sh - Create rsync snapshot backup with hard-link incrementals
#
# USAGE:
#   sudo ./run_backup.sh [/srv/greendev-data]
#
# Creates:
#   /srv/greendev-data/backups/snapshots/<timestamp>
#   /srv/greendev-data/backups/snapshots/latest -> <timestamp>
#
# Backup sources:
#   /home/greendevcorp
#   /opt/gsx-admin
#   /etc/ssh
#   /etc/sudoers
#   /etc/sudoers.d
#   /etc/security/limits.d
#   /etc/profile.d/greendevcorp.sh

require_root

DATA_ROOT="${1:-/srv/greendev-data}"
SNAPSHOT_ROOT="$DATA_ROOT/backups/snapshots"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
SNAPSHOT="$SNAPSHOT_ROOT/$TIMESTAMP"
LATEST_LINK="$SNAPSHOT_ROOT/latest"
LOG_FILE="/var/log/gsx/week5-backup.log"

SOURCES=(
    "/home/greendevcorp"
    "/opt/gsx-admin"
    "/etc/ssh"
    "/etc/sudoers"
    "/etc/sudoers.d"
    "/etc/security/limits.d"
    "/etc/profile.d/greendevcorp.sh"
)

mkdir -p "$SNAPSHOT_ROOT" "$(dirname "$LOG_FILE")"

if ! mountpoint -q "$DATA_ROOT"; then
    output_message ERROR "$DATA_ROOT is not a mountpoint. Refusing to write backups to an unmounted path."
    exit 1
fi

output_message INFO "Starting Week 5 backup snapshot: $SNAPSHOT"
echo "$(date --iso-8601=seconds) START $SNAPSHOT" >> "$LOG_FILE"

mkdir -p "$SNAPSHOT"

RSYNC_ARGS=(-aHAX --numeric-ids --delete --relative)

if [ -L "$LATEST_LINK" ] && [ -d "$LATEST_LINK" ]; then
    PREVIOUS="$(readlink -f "$LATEST_LINK")"
    RSYNC_ARGS+=(--link-dest="$PREVIOUS")
    output_message INFO "Using previous snapshot for hard-link incrementals: $PREVIOUS"
fi

for src in "${SOURCES[@]}"; do
    if [ -e "$src" ]; then
        output_message INFO "Backing up $src"
        rsync "${RSYNC_ARGS[@]}" "$src" "$SNAPSHOT/"
    else
        output_message WARNING "Skipping missing source: $src"
    fi
done

output_message INFO "Generating SHA256 manifest..."
(
    cd "$SNAPSHOT"
    find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
)

output_message INFO "Verifying manifest..."
(
    cd "$SNAPSHOT"
    sha256sum -c SHA256SUMS >/dev/null
)

ln -sfn "$SNAPSHOT" "$LATEST_LINK"

echo "$(date --iso-8601=seconds) SUCCESS $SNAPSHOT" >> "$LOG_FILE"
output_message SUCCESS "Backup snapshot completed: $SNAPSHOT"
du -sh "$SNAPSHOT" "$SNAPSHOT_ROOT" 2>/dev/null || true
