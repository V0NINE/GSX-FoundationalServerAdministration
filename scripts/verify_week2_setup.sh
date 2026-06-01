#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/script_message.sh"

FAILED=0

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        output_message SUCCESS "$description"
    else
        output_message ERROR "$description"
        FAILED=1
    fi
}

check "Nginx package is installed" dpkg -s nginx
check "Nginx service is enabled" systemctl is-enabled -q nginx
check "Nginx service is active" systemctl is-active -q nginx
check "Nginx responds on localhost" curl -fsS http://localhost
check "Nginx override exists" test -f /etc/systemd/system/nginx.service.d/override.conf
check "GSX backup service exists" test -f /etc/systemd/system/gsx-backup.service
check "GSX backup timer exists" test -f /etc/systemd/system/gsx-backup.timer
check "GSX backup timer is enabled" systemctl is-enabled -q gsx-backup.timer
check "GSX backup timer is active" systemctl is-active -q gsx-backup.timer
check "journald retention config exists" test -f /etc/systemd/journald.conf.d/gsx-retention.conf
check "Latest backup exists" test -e /var/backups/gsx/latest-week1-admin.tar.gz
check "Latest backup archive is readable" tar -tzf /var/backups/gsx/latest-week1-admin.tar.gz

if [ "$FAILED" -eq 0 ]; then
    output_message SUCCESS "Week 2 verification passed."
else
    output_message ERROR "Week 2 verification failed."
fi

exit "$FAILED"
