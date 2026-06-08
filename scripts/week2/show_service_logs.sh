#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-}"
SINCE="${2:-1 hour ago}"

if [ -z "$SERVICE" ]; then
    echo "USAGE: $0 <service> [since]" >&2
    echo "EXAMPLE: $0 nginx '10 minutes ago'" >&2
    exit 1
fi

journalctl -u "$SERVICE" --since "$SINCE" --no-pager
