#!/usr/bin/env bash
# check_cgroup_limits.sh - Show cgroup resource controls for a systemd unit
#
# USAGE:
#   ./check_cgroup_limits.sh [unit]

set -euo pipefail

UNIT="${1:-gsx-workload.service}"

echo "== systemd resource properties for $UNIT =="
systemctl show "$UNIT" \
    -p ControlGroup \
    -p CPUQuotaPerSecUSec \
    -p MemoryMax \
    -p TasksMax \
    -p MainPID \
    --no-pager

CONTROL_GROUP="$(systemctl show "$UNIT" -p ControlGroup --value)"
MAIN_PID="$(systemctl show "$UNIT" -p MainPID --value)"

echo
echo "== Main PID =="
echo "$MAIN_PID"

if [ -n "$MAIN_PID" ] && [ "$MAIN_PID" != "0" ]; then
    echo
    echo "== Process metrics =="
    ps -p "$MAIN_PID" -o pid,ppid,user,stat,pri,ni,%cpu,%mem,rss,vsz,etime,comm,args || true
fi

if [ -n "$CONTROL_GROUP" ]; then
    CGROUP_PATH="/sys/fs/cgroup${CONTROL_GROUP}"
    echo
    echo "== Cgroup path =="
    echo "$CGROUP_PATH"

    echo
    echo "== Cgroup files =="
    for file in cpu.max memory.max memory.current pids.max pids.current cgroup.procs; do
        if [ -f "$CGROUP_PATH/$file" ]; then
            echo "--- $file ---"
            cat "$CGROUP_PATH/$file"
        fi
    done
fi
