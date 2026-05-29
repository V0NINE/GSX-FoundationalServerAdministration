#!/usr/bin/env bash
# setup_admin_dirs.sh - Create administrative directory structure
#
# PURPOSE:
#   Create a shared administrative structure for scripts, configs, backups,
#   documentation and logs.
#
# USAGE:
#   sudo ./setup_admin_dirs.sh [admin_group]
#
# DEFAULT:
#   admin_group = gsxadmin
#
# IDEMPOTENCE:
#   Safe to run multiple times.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/script_message.sh"

require_root

ADMIN_GROUP="${1:-gsxadmin}"
ADMIN_ROOT="/opt/gsx-admin"

DIRS=(
    "$ADMIN_ROOT"
    "$ADMIN_ROOT/scripts"
    "$ADMIN_ROOT/configs"
    "$ADMIN_ROOT/docs"
    "$ADMIN_ROOT/logs"
    "/var/backups/gsx"
)

if ! getent group "$ADMIN_GROUP" >/dev/null; then
    groupadd "$ADMIN_GROUP"
    output_message SUCCESS "Created group $ADMIN_GROUP."
else
    output_message WARNING "Group $ADMIN_GROUP already exists."
fi

for dir in "${DIRS[@]}"; do
    mkdir -p "$dir"
    chown root:"$ADMIN_GROUP" "$dir"
done

chmod 2775 "$ADMIN_ROOT"
chmod 2775 "$ADMIN_ROOT/scripts" "$ADMIN_ROOT/configs" "$ADMIN_ROOT/docs" "$ADMIN_ROOT/logs"
chmod 2770 "/var/backups/gsx"

output_message SUCCESS "Administrative directories are ready:"
for dir in "${DIRS[@]}"; do
    ls -ld "$dir"
done
