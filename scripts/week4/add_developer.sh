#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

# add_developer.sh - Add one developer to the GreenDevCorp team
#
# USAGE:
#   sudo ./add_developer.sh <username>
#
# EXAMPLE:
#   sudo ./add_developer.sh dev5

require_root

USER_NAME="${1:-}"
TEAM_GROUP="greendevcorp"

if [ -z "$USER_NAME" ]; then
    output_message ERROR "USAGE: $0 <username>"
    exit 1
fi

if ! getent group "$TEAM_GROUP" >/dev/null; then
    groupadd "$TEAM_GROUP"
    output_message SUCCESS "Created group $TEAM_GROUP."
fi

if id "$USER_NAME" >/dev/null 2>&1; then
    output_message WARNING "User $USER_NAME already exists."
else
    useradd -m -s /bin/bash "$USER_NAME"
    passwd -l "$USER_NAME" >/dev/null
    output_message SUCCESS "Created user $USER_NAME with locked password."
fi

usermod -aG "$TEAM_GROUP" "$USER_NAME"

HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
if [ -n "$HOME_DIR" ] && [ -d "$HOME_DIR" ]; then
    chown "$USER_NAME:$USER_NAME" "$HOME_DIR"
    chmod 0700 "$HOME_DIR"
fi

output_message SUCCESS "User $USER_NAME is a member of $TEAM_GROUP and has a private home directory."
