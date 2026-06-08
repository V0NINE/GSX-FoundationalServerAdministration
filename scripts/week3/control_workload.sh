#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

ACTION="${1:-}"
PID_FILE="/tmp/gsx-week3-workload/workload.pid"

if [ -z "$ACTION" ]; then
    echo "USAGE: $0 <status|pause|stop|kill>" >&2
    exit 1
fi

if [ ! -f "$PID_FILE" ]; then
    output_message ERROR "No workload PID file found. Start it with start_workload_demo.sh."
    exit 1
fi

PID="$(cat "$PID_FILE")"

if ! kill -0 "$PID" 2>/dev/null; then
    output_message ERROR "Workload PID $PID is not running."
    exit 1
fi

case "$ACTION" in
    status)
        output_message INFO "Sending SIGUSR1 to $PID."
        kill -USR1 "$PID"
        ;;
    pause|resume|toggle)
        output_message INFO "Sending SIGUSR2 to $PID."
        kill -USR2 "$PID"
        ;;
    stop|term|graceful)
        output_message INFO "Sending SIGTERM to $PID."
        kill -TERM "$PID"
        ;;
    kill|force)
        output_message WARNING "Sending SIGKILL to $PID. This is not graceful."
        kill -KILL "$PID"
        ;;
    *)
        echo "USAGE: $0 <status|pause|stop|kill>" >&2
        exit 1
        ;;
esac

sleep 1
output_message INFO "Recent workload log:"
tail -n 20 /tmp/gsx-week3-workload/workload.log 2>/dev/null || true
