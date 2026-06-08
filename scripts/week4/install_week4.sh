#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

# install_week4.sh - One-command Week 4 setup
#
# USAGE:
#   sudo ./install_week4.sh

require_root

"$SCRIPT_DIR/setup_week4_tools.sh"
"$SCRIPT_DIR/setup_users_groups.sh"
"$SCRIPT_DIR/setup_team_directories.sh"
"$SCRIPT_DIR/setup_pam_limits.sh"
"$SCRIPT_DIR/setup_team_environment.sh"
"$SCRIPT_DIR/verify_week4_setup.sh"

output_message SUCCESS "Week 4 baseline setup completed."
