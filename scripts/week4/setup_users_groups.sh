#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

# setup_users_groups.sh - Create Week 4 users and group structure
#
# USAGE:
#   sudo ./setup_users_groups.sh
#
# Creates:
#   group: greendevcorp
#   users: dev1, dev2, dev3, dev4

require_root

TEAM_GROUP="greendevcorp"
DEVS=(dev1 dev2 dev3 dev4)

if ! getent group "$TEAM_GROUP" >/dev/null; then
    groupadd "$TEAM_GROUP"
    output_message SUCCESS "Created group $TEAM_GROUP."
else
    output_message WARNING "Group $TEAM_GROUP already exists."
fi

for dev in "${DEVS[@]}"; do
    "$SCRIPT_DIR/add_developer.sh" "$dev"
done

output_message SUCCESS "Week 4 users and groups are configured."
