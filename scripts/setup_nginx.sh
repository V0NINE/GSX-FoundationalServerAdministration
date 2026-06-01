#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/script_message.sh"

require_root

NGINX_SERVICE="nginx"
OVERRIDE_DIR="/etc/systemd/system/nginx.service.d"
OVERRIDE_FILE="$OVERRIDE_DIR/override.conf"

output_message INFO "Installing Nginx if needed..."
if ! dpkg -s nginx >/dev/null 2>&1; then
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl
    output_message SUCCESS "Nginx installed."
else
    output_message WARNING "Nginx is already installed."
fi

output_message INFO "Configuring systemd restart policy for Nginx..."
mkdir -p "$OVERRIDE_DIR"
cat > "$OVERRIDE_FILE" <<'EOF'
[Service]
Restart=on-failure
RestartSec=5s
EOF
chmod 0644 "$OVERRIDE_FILE"

systemctl daemon-reload
systemctl enable "$NGINX_SERVICE"
systemctl restart "$NGINX_SERVICE"

if systemctl is-active -q "$NGINX_SERVICE"; then
    output_message SUCCESS "Nginx is active."
else
    output_message ERROR "Nginx is not active."
    systemctl status "$NGINX_SERVICE" --no-pager || true
    exit 1
fi

if curl -fsS http://localhost >/dev/null; then
    output_message SUCCESS "Nginx responds on http://localhost."
else
    output_message ERROR "Nginx does not respond on http://localhost."
    exit 1
fi
