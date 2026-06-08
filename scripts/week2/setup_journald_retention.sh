#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

require_root

CONF_DIR="/etc/systemd/journald.conf.d"
CONF_FILE="$CONF_DIR/gsx-retention.conf"

mkdir -p "$CONF_DIR"

cat > "$CONF_FILE" <<'EOF'
[Journal]
SystemMaxUse=200M
MaxRetentionSec=7day
Compress=yes
EOF

chmod 0644 "$CONF_FILE"
systemctl restart systemd-journald

output_message SUCCESS "journald retention configured in $CONF_FILE."
journalctl --disk-usage || true
