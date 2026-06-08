#!/usr/bin/env bash
# backup_admin_data.sh - Create a tar backup preserving attributes
#
# PURPOSE:
#   Package important Week 1 administrative data into /var/backups/gsx.
#
# USAGE:
#   sudo ./backup_admin_data.sh
#
# WHAT IT BACKS UP:
#   /opt/gsx-admin
#   /etc/ssh/sshd_config
#   /etc/ssh/sshd_config.d
#   /etc/sudoers
#   /etc/sudoers.d
#
# NOTES:
#   Uses tar with permissions, numeric owners, ACLs and xattrs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

require_root

BACKUP_DIR="/var/backups/gsx"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
HOSTNAME_SHORT="$(hostname -s)"
BACKUP_FILE="$BACKUP_DIR/${HOSTNAME_SHORT}-week1-admin-${TIMESTAMP}.tar.gz"
LATEST_LINK="$BACKUP_DIR/latest-week1-admin.tar.gz"
LOG_FILE="/opt/gsx-admin/logs/backup.log"

SOURCES=(
    "/opt/gsx-admin"
    "/etc/ssh/sshd_config"
    "/etc/ssh/sshd_config.d"
    "/etc/sudoers"
    "/etc/sudoers.d"
)

mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

EXISTING_SOURCES=()
for src in "${SOURCES[@]}"; do
    if [ -e "$src" ]; then
        EXISTING_SOURCES+=("$src")
    else
        output_message WARNING "Skipping missing source: $src"
    fi
done

if [ "${#EXISTING_SOURCES[@]}" -eq 0 ]; then
    output_message ERROR "No backup sources exist."
    exit 1
fi

output_message INFO "Creating backup: $BACKUP_FILE"

tar \
    --create \
    --gzip \
    --file "$BACKUP_FILE" \
    --absolute-names \
    --preserve-permissions \
    --numeric-owner \
    --acls \
    --xattrs \
    "${EXISTING_SOURCES[@]}"

chmod 0640 "$BACKUP_FILE"
ln -sfn "$BACKUP_FILE" "$LATEST_LINK"

if tar -tzf "$BACKUP_FILE" >/dev/null; then
    echo "$(date --iso-8601=seconds) SUCCESS $BACKUP_FILE" >> "$LOG_FILE"
    output_message SUCCESS "Backup created and verified: $BACKUP_FILE"
else
    echo "$(date --iso-8601=seconds) ERROR $BACKUP_FILE" >> "$LOG_FILE"
    output_message ERROR "Backup verification failed."
    exit 2
fi
