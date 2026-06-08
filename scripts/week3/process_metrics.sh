#!/usr/bin/env bash
# process_metrics.sh - Show metrics for a specific process
#
# USAGE:
#   ./process_metrics.sh <pid>

set -euo pipefail

PID="${1:-}"

if [ -z "$PID" ]; then
    echo "USAGE: $0 <pid>" >&2
    exit 1
fi

if [ ! -d "/proc/$PID" ]; then
    echo "Process $PID does not exist." >&2
    exit 1
fi

echo "== Basic process information =="
ps -p "$PID" -o pid,ppid,user,stat,pri,ni,%cpu,%mem,rss,vsz,etime,comm,args

echo
echo "== /proc/$PID/status highlights =="
grep -E '^(Name|State|Pid|PPid|Uid|Gid|Threads|VmPeak|VmSize|VmRSS|VmData|VmStk|VmExe|voluntary_ctxt_switches|nonvoluntary_ctxt_switches):' "/proc/$PID/status" || true

echo
echo "== Open file descriptors count =="
if [ -d "/proc/$PID/fd" ]; then
    ls -1 "/proc/$PID/fd" 2>/dev/null | wc -l
else
    echo "Cannot access /proc/$PID/fd"
fi

echo
echo "== Cgroup membership =="
cat "/proc/$PID/cgroup" || true

echo
echo "== Limits =="
cat "/proc/$PID/limits" || true
