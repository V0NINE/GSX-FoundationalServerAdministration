#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

FAILED=0

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        output_message SUCCESS "$description"
    else
        output_message ERROR "$description"
        FAILED=1
    fi
}

check "ps command exists" command -v ps
check "pstree command exists" command -v pstree
check "sysstat package is installed" dpkg -s sysstat
check "stress-ng is installed" command -v stress-ng
check "list_top_processes.sh exists" test -x "$SCRIPT_DIR/list_top_processes.sh"
check "show_process_tree.sh exists" test -x "$SCRIPT_DIR/show_process_tree.sh"
check "process_metrics.sh exists" test -x "$SCRIPT_DIR/process_metrics.sh"
check "signal_aware_workload.sh exists" test -x "$SCRIPT_DIR/signal_aware_workload.sh"
check "gsx-workload.service exists" test -f /etc/systemd/system/gsx-workload.service
check "gsx-workload.service is enabled" systemctl is-enabled -q gsx-workload.service

if systemctl is-active -q gsx-workload.service; then
    output_message SUCCESS "gsx-workload.service is active"
else
    output_message WARNING "gsx-workload.service is installed but not currently active"
fi

if [ "$FAILED" -eq 0 ]; then
    output_message SUCCESS "Week 3 verification passed."
else
    output_message ERROR "Week 3 verification failed."
fi

exit "$FAILED"
