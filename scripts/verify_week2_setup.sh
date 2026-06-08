#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/script_message.sh"

FAILED=0

check_or_fail() {
    local start_description="$1"
    local end_description="$2"
    shift
    shift

    if "$@"; then
        output_message SUCCESS "$start_description $end_description"
    else
        output_message ERROR "$start_description not $end_description"
        FAILED=1
    fi
}

check_or_fail "Nginx package is" "installed" dpkg -s nginx
check_or_fail "Nginx service is" "enabled" systemctl is-enabled -q nginx
check_or_fail "Nginx service is" "active" systemctl is-active -q nginx
check_or_fail "Nginx" "responds on localhost" curl -fsS http://localhost
check_or_fail "Nginx override" "exists" test -f /etc/systemd/system/nginx.service.d/override.conf
check_or_fail "GSX backup service" "exists" test -f /etc/systemd/system/gsx-backup.service
check_or_fail "GSX backup timer" "exists" test -f /etc/systemd/system/gsx-backup.timer
check_or_fail "GSX backup timer is" "enabled" systemctl is-enabled -q gsx-backup.timer
check_or_fail "GSX backup timer is" "active" systemctl is-active -q gsx-backup.timer
check_or_fail "journald retention config" "exists" test -f /etc/systemd/journald.conf.d/gsx-retention.conf
check_or_fail "Latest backup" "exists" test -e /var/backups/gsx/latest-week1-admin.tar.gz
check "Latest backup archive is" "readable" tar -tzf /var/backups/gsx/latest-week1-admin.tar.gz

if [ "$FAILED" -eq 0 ]; then
    output_message SUCCESS "Week 2 verification passed."
else
    output_message ERROR "Week 2 verification failed."
fi

exit "$FAILED"
