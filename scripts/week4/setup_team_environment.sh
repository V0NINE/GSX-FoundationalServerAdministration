#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

# setup_team_environment.sh - Configure shared shell environment for GreenDevCorp users
#
# USAGE:
#   sudo ./setup_team_environment.sh

require_root

PROFILE_FILE="/etc/profile.d/greendevcorp.sh"

cat > "$PROFILE_FILE" <<'EOF'
# GreenDevCorp shared shell environment.
# Managed by GSX Week 4 scripts.

if id -nG "$USER" 2>/dev/null | grep -qw greendevcorp; then
    export GREENDEVCORP_HOME="/home/greendevcorp"
    export GREENDEVCORP_SHARED="/home/greendevcorp/shared"
    export PATH="/home/greendevcorp/bin:$PATH"

    alias ll='ls -alF'
    alias gsx-shared='cd /home/greendevcorp/shared'
    alias gsx-done='cat /home/greendevcorp/done.log'
fi
EOF

chmod 0644 "$PROFILE_FILE"

output_message SUCCESS "Team shell environment configured in $PROFILE_FILE."
