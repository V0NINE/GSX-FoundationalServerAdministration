#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

require_root

"$SCRIPT_DIR/setup_week3_tools.sh"
"$SCRIPT_DIR/setup_workload_service.sh"
"$SCRIPT_DIR/verify_week3_setup.sh"

output_message SUCCESS "Week 3 baseline setup completed."
