#!/usr/bin/env bash
# verify_week1_setup.sh - Verify and optionally repair Week 1 setup
#
# PURPOSE:
#   Check the baseline Week 1 configuration and re-apply what is safe to fix.
#
# USAGE:
#   sudo ./verify_week1_setup.sh [--fix] [--ssh-mode bootstrap|secure]
#
# EXAMPLES:
#   sudo ./verify_week1_setup.sh
#   sudo ./verify_week1_setup.sh --fix
#   sudo ./verify_week1_setup.sh --fix --ssh-mode secure
#
# EXIT CODES:
#   0 = all checks passed
#   1 = at least one check failed

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/script_message.sh"

require_root

FIX=0
SSH_MODE="bootstrap"
FAILED=0

usage() {
    output_message INFO "USAGE: $0 [--fix] [--ssh-mode bootstrap|secure]"
    exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --fix)
            FIX=1
            shift
            ;;
        --ssh-mode)
            shift
            SSH_MODE="${1:-}"
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

check_or_fail() {
    local description="$1"
    shift

    if "$@"; then
        output_message SUCCESS "$description"
    else
        output_message ERROR "$description"
        FAILED=1
    fi
}

package_installed() {
    dpkg -s "$1" >/dev/null 2>&1
}

service_active() {
    systemctl is-active -q "$1"
}

service_enabled() {
    systemctl is-enabled -q "$1"
}

dir_exists() {
    [ -d "$1" ]
}

file_exists() {
    [ -f "$1" ]
}

output_message INFO "Running Week 1 verification..."

if [ "$FIX" -eq 1 ]; then
    output_message INFO "Fix mode enabled. Re-applying safe baseline setup..."
    "$SCRIPT_DIR/setup_basic_packages.sh"
    "$SCRIPT_DIR/setup_admin_dirs.sh"
    "$SCRIPT_DIR/setup_ssh_server.sh"
    "$SCRIPT_DIR/configure_ssh_access.sh" --mode "$SSH_MODE"
fi

check_or_fail "Package sudo is installed" package_installed sudo
check_or_fail "Package git is installed" package_installed git
check_or_fail "Package openssh-server is installed" package_installed openssh-server
check_or_fail "SSH service is enabled" service_enabled ssh
check_or_fail "SSH service is active" service_active ssh
check_or_fail "sshd configuration is valid" sshd -t
check_or_fail "/opt/gsx-admin exists" dir_exists /opt/gsx-admin
check_or_fail "/opt/gsx-admin/scripts exists" dir_exists /opt/gsx-admin/scripts
check_or_fail "/opt/gsx-admin/configs exists" dir_exists /opt/gsx-admin/configs
check_or_fail "/opt/gsx-admin/docs exists" dir_exists /opt/gsx-admin/docs
check_or_fail "/var/backups/gsx exists" dir_exists /var/backups/gsx
check_or_fail "Custom SSH config exists" file_exists /etc/ssh/sshd_config.d/50-gsx-custom.conf

if id gsx >/dev/null 2>&1; then
    output_message SUCCESS "User gsx exists"
else
    output_message ERROR "User gsx does not exist"
    FAILED=1
fi

if [ "$FAILED" -eq 0 ]; then
    output_message SUCCESS "Week 1 baseline verification passed."
else
    output_message ERROR "Week 1 baseline verification failed."
fi

exit "$FAILED"
