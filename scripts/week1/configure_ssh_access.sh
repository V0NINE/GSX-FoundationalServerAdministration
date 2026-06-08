#!/usr/bin/env bash
# configure_ssh_access.sh - Configure SSH access mode
#
# USAGE:
#   sudo ./configure_ssh_access.sh --mode bootstrap
#   sudo ./configure_ssh_access.sh --mode secure
#
# MODES:
#   bootstrap: password login allowed, useful before keys are installed
#   secure:    password login disabled, key-based access only
#
# IDEMPOTENCE:
#   Safe to run multiple times. If config is already correct, exits 0.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

require_root

MODE=""
CONF_DIR="/etc/ssh/sshd_config.d"
CONF_FILE="$CONF_DIR/50-gsx-custom.conf"

usage() {
    output_message INFO "USAGE: $0 --mode <bootstrap|secure>"
    exit 1
}

generate_config() {
    case "$1" in
        bootstrap)
            cat <<'EOF'
# Managed by GSX Week 1 scripts
PermitRootLogin prohibit-password
PasswordAuthentication yes
PubkeyAuthentication yes
KbdInteractiveAuthentication no
UsePAM yes
EOF
            ;;
        secure)
            cat <<'EOF'
# Managed by GSX Week 1 scripts
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
KbdInteractiveAuthentication no
UsePAM yes
EOF
            ;;
        *)
            output_message ERROR "Unknown mode: $1"
            return 1
            ;;
    esac
}

if [ $# -lt 1 ]; then
    usage
fi

case "$1" in
    --mode)
        shift
        MODE="${1:-}"
        ;;
    -h|--help)
        usage
        ;;
    *)
        output_message ERROR "Unknown argument: $1"
        usage
        ;;
esac

if [ -z "$MODE" ]; then
    output_message ERROR "--mode is required."
    usage
fi

NEW_CONF="$(generate_config "$MODE")"

mkdir -p "$CONF_DIR"

if [ -f "$CONF_FILE" ] && diff -q <(printf "%s\n" "$NEW_CONF") "$CONF_FILE" >/dev/null; then
    output_message WARNING "SSH configuration is already in $MODE mode. No changes applied."
else
    printf "%s\n" "$NEW_CONF" > "$CONF_FILE"
    chmod 644 "$CONF_FILE"
    output_message SUCCESS "SSH configuration written to $CONF_FILE."
fi

if ! sshd -t; then
    output_message ERROR "SSH configuration is invalid. Check $CONF_FILE."
    exit 2
fi

systemctl restart ssh
output_message SUCCESS "SSH service restarted successfully."
