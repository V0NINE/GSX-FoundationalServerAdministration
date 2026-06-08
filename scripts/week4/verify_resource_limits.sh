#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

# verify_resource_limits.sh - Verify PAM limits for GreenDevCorp developers
#
# USAGE:
#   sudo ./verify_resource_limits.sh

require_root

FAILED=0
USER_TO_TEST="${1:-dev1}"

pass() { output_message SUCCESS "$1"; }
fail() { output_message ERROR "$1"; FAILED=1; }

if ! id "$USER_TO_TEST" >/dev/null 2>&1; then
    fail "User $USER_TO_TEST does not exist"
    exit 1
fi

LIMITS_FILE="/etc/security/limits.d/90-greendevcorp.conf"

if [ -f "$LIMITS_FILE" ]; then
    pass "$LIMITS_FILE exists"
else
    fail "$LIMITS_FILE does not exist"
fi

for pam_file in /etc/pam.d/common-session /etc/pam.d/common-session-noninteractive; do
    if [ -f "$pam_file" ] && grep -Eq '^session\s+required\s+pam_limits\.so' "$pam_file"; then
        pass "pam_limits.so enabled in $pam_file"
    else
        fail "pam_limits.so not enabled in $pam_file"
    fi
done

get_limit() {
    local option="$1"
    su -l "$USER_TO_TEST" -s /bin/bash -c "ulimit $option" 2>/dev/null | tail -n 1
}

NOFILE="$(get_limit -n || true)"
NPROC="$(get_limit -u || true)"
VMEM="$(get_limit -v || true)"
CPU="$(get_limit -t || true)"

echo "Observed soft limits for $USER_TO_TEST:"
echo "  open files (-n): $NOFILE"
echo "  processes  (-u): $NPROC"
echo "  vmem KB    (-v): $VMEM"
echo "  CPU sec    (-t): $CPU"

[ -n "$NOFILE" ] && [ "$NOFILE" != "unlimited" ] && pass "Open files limit is set" || fail "Open files limit is not set"
[ -n "$NPROC" ] && [ "$NPROC" != "unlimited" ] && pass "Max processes limit is set" || fail "Max processes limit is not set"
[ -n "$VMEM" ] && [ "$VMEM" != "unlimited" ] && pass "Memory/address-space limit is set" || fail "Memory/address-space limit is not set"
[ -n "$CPU" ] && [ "$CPU" != "unlimited" ] && pass "CPU time limit is set" || fail "CPU time limit is not set"

if [ "$FAILED" -eq 0 ]; then
    output_message SUCCESS "Resource-limits verification passed."
else
    output_message ERROR "Resource-limits verification failed."
fi

exit "$FAILED"
