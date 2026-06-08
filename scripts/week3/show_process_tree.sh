#!/usr/bin/env bash
# show_process_tree.sh - Show process tree and parent-child relationships
#
# USAGE:
#   ./show_process_tree.sh
#   ./show_process_tree.sh <pid>

set -euo pipefail

PID="${1:-}"

if ! command -v pstree >/dev/null 2>&1; then
    echo "pstree not found. Install psmisc or run setup_week3_tools.sh." >&2
    exit 1
fi

if [ -n "$PID" ]; then
    pstree -aps "$PID"
else
    pstree -ap
fi
