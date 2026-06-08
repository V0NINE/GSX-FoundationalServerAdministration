#!/usr/bin/env bash
# list_top_processes.sh - List top CPU or memory consumers
#
# USAGE:
#   ./list_top_processes.sh [cpu|mem] [limit]

set -euo pipefail

SORT_BY="${1:-cpu}"
LIMIT="${2:-10}"

case "$SORT_BY" in
    cpu)
        SORT_FIELD="-%cpu"
        TITLE="Top processes by CPU"
        ;;
    mem|memory)
        SORT_FIELD="-%mem"
        TITLE="Top processes by memory"
        ;;
    *)
        echo "USAGE: $0 [cpu|mem] [limit]" >&2
        exit 1
        ;;
esac

echo "== $TITLE =="
echo "Limit: $LIMIT"
echo

ps -eo pid,ppid,user,stat,pri,ni,%cpu,%mem,rss,vsz,etime,comm,args \
    --sort="$SORT_FIELD" \
    | head -n "$((LIMIT + 1))"
