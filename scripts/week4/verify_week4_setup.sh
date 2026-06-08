#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

# verify_week4_setup.sh - Run all Week 4 verification checks
#
# USAGE:
#   sudo ./verify_week4_setup.sh

require_root

FAILED=0

if "$SCRIPT_DIR/verify_access_control.sh"; then
    output_message SUCCESS "Access-control checks passed."
else
    output_message ERROR "Access-control checks failed."
    FAILED=1
fi

if "$SCRIPT_DIR/verify_resource_limits.sh" dev1; then
    output_message SUCCESS "Resource-limit checks passed."
else
    output_message ERROR "Resource-limit checks failed."
    FAILED=1
fi

if [ "$FAILED" -eq 0 ]; then
    output_message SUCCESS "Week 4 verification passed."
else
    output_message ERROR "Week 4 verification failed."
fi

exit "$FAILED"
