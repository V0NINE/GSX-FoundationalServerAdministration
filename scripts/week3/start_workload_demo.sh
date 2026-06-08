#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

WORKERS="${1:-2}"
RUN_DIR="/tmp/gsx-week3-workload"
PID_FILE="$RUN_DIR/workload.pid"

mkdir -p "$RUN_DIR"

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    output_message WARNING "Workload already running with PID $(cat "$PID_FILE")."
    exit 0
fi

output_message INFO "Starting workload demo with $WORKERS workers..."
nohup "$SCRIPT_DIR/signal_aware_workload.sh" "$WORKERS" >"$RUN_DIR/nohup.out" 2>&1 &
sleep 1

if [ -f "$PID_FILE" ]; then
    output_message SUCCESS "Workload started. Main PID: $(cat "$PID_FILE")"
    output_message INFO "Log: $RUN_DIR/workload.log"
else
    output_message ERROR "Workload did not start correctly."
    exit 1
fi
