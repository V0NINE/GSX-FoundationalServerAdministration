#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

require_root

SERVICE_FILE="/etc/systemd/system/gsx-workload.service"
WORKLOAD_SRC="$SCRIPT_DIR/signal_aware_workload.sh"
WORKLOAD_DST="/opt/gsx-admin/scripts/week3/signal_aware_workload.sh"

mkdir -p "$(dirname "$WORKLOAD_DST")"
install -m 0755 "$WORKLOAD_SRC" "$WORKLOAD_DST"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=GSX Week 3 resource-limited workload demo
After=network.target

[Service]
Type=simple
ExecStart=$WORKLOAD_DST 4
Restart=on-failure
RestartSec=3s

CPUQuota=50%
MemoryMax=150M
TasksMax=50

NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

chmod 0644 "$SERVICE_FILE"
systemctl daemon-reload
systemctl enable gsx-workload.service

output_message SUCCESS "Installed gsx-workload.service with CPUQuota=50%, MemoryMax=150M, TasksMax=50."
output_message INFO "Start it with: sudo systemctl start gsx-workload.service"
