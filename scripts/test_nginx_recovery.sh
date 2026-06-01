#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/script_message.sh"

require_root

SERVICE="nginx"

if ! systemctl is-active -q "$SERVICE"; then
    output_message ERROR "$SERVICE is not active before the test."
    exit 1
fi

output_message WARNING "Killing $SERVICE processes through systemd to simulate failure..."
systemctl kill "$SERVICE" --signal=SIGKILL || true

output_message INFO "Waiting 8 seconds for systemd recovery..."
sleep 8

if systemctl is-active -q "$SERVICE"; then
    output_message SUCCESS "$SERVICE recovered and is active."
else
    output_message ERROR "$SERVICE did not recover."
    systemctl status "$SERVICE" --no-pager || true
    journalctl -u "$SERVICE" --since "2 minutes ago" --no-pager || true
    exit 1
fi

output_message INFO "Recent Nginx logs:"
journalctl -u "$SERVICE" --since "2 minutes ago" --no-pager || true
