#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/script_message.sh"

require_root

"$SCRIPT_DIR/week2/setup_nginx.sh"
"$SCRIPT_DIR/week2/setup_backup_timer.sh"
"$SCRIPT_DIR/week2/setup_journald_retention.sh"
"$SCRIPT_DIR/verify_week2_setup.sh"

output_message SUCCESS "Week 2 baseline setup completed."
