#!/usr/bin/env bash
# monitor_unit_resources.sh - Monitor basic resource use for a systemd unit
#
# USAGE:
#   ./monitor_unit_resources.sh [unit] [interval] [samples]

set -euo pipefail

UNIT="${1:-gsx-workload.service}"
INTERVAL="${2:-2}"
SAMPLES="${3:-10}"

for i in $(seq 1 "$SAMPLES"); do
    MAIN_PID="$(systemctl show "$UNIT" -p MainPID --value 2>/dev/null || echo 0)"
    echo "== Sample $i/$SAMPLES at $(date --iso-8601=seconds) =="

    if [ -n "$MAIN_PID" ] && [ "$MAIN_PID" != "0" ]; then
        ps -p "$MAIN_PID" -o pid,ppid,stat,%cpu,%mem,rss,vsz,etime,comm,args || true
        children="$(pgrep -P "$MAIN_PID" | paste -sd, - || true)"
        if [ -n "$children" ]; then
            echo "Children: $children"
            ps -o pid,ppid,stat,%cpu,%mem,rss,vsz,etime,comm,args -p "$children" || true
        fi
    else
        echo "$UNIT is not running or has no MainPID."
    fi

    echo
    sleep "$INTERVAL"
done
