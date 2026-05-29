#!/usr/bin/env bash
# install_week1.sh - One-command Week 1 baseline installation
#
# USAGE:
#   sudo ./install_week1.sh [--ssh-mode bootstrap|secure] [--sudo-user username]
#
# DEFAULTS:
#   ssh-mode = bootstrap
#   sudo-user = current SUDO_USER, or gsx if unavailable
#
# NOTE:
#   Use bootstrap first. Switch to secure only after SSH keys work.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/script_message.sh"

require_root

SSH_MODE="bootstrap"
SUDO_USER_TO_ADD="${SUDO_USER:-gsx}"

usage() {
    output_message INFO "USAGE: $0 [--ssh-mode bootstrap|secure] [--sudo-user username]"
    exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --ssh-mode)
            shift
            SSH_MODE="${1:-}"
            shift || true
            ;;
        --sudo-user)
            shift
            SUDO_USER_TO_ADD="${1:-}"
            shift || true
            ;;
        -h|--help)
            usage
            ;;
        *)
            output_message ERROR "Unknown argument: $1"
            usage
            ;;
    esac
done

if [[ "$SSH_MODE" != "bootstrap" && "$SSH_MODE" != "secure" ]]; then
    output_message ERROR "Invalid SSH mode: $SSH_MODE"
    usage
fi

output_message INFO "Starting Week 1 baseline installation..."

"$SCRIPT_DIR/setup_basic_packages.sh"
"$SCRIPT_DIR/setup_admin_dirs.sh"
"$SCRIPT_DIR/setup_ssh_server.sh"
"$SCRIPT_DIR/configure_ssh_access.sh" --mode "$SSH_MODE"

if id "$SUDO_USER_TO_ADD" >/dev/null 2>&1; then
    "$SCRIPT_DIR/configure_sudoers.sh" "$SUDO_USER_TO_ADD" || true
else
    output_message WARNING "User $SUDO_USER_TO_ADD does not exist. Skipping sudoers setup."
fi

"$SCRIPT_DIR/backup_admin_data.sh"
"$SCRIPT_DIR/verify_week1_setup.sh" --ssh-mode "$SSH_MODE"

output_message SUCCESS "Week 1 baseline installation completed."
