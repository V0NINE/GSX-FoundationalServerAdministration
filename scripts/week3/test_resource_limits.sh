#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

require_root

output_message INFO "Installing and starting resource-limited workload service..."
"$SCRIPT_DIR/setup_workload_service.sh"

systemctl restart gsx-workload.service
sleep 3

if systemctl is-active -q gsx-workload.service; then
    output_message SUCCESS "gsx-workload.service is active."
else
    output_message ERROR "gsx-workload.service is not active."
    systemctl status gsx-workload.service --no-pager || true
    exit 1
fi

output_message INFO "Showing cgroup limits:"
"$SCRIPT_DIR/check_cgroup_limits.sh" gsx-workload.service

output_message INFO "Monitoring resource usage:"
"$SCRIPT_DIR/monitor_unit_resources.sh" gsx-workload.service 1 5

output_message SUCCESS "Resource limit demonstration finished."
