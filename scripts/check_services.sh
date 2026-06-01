#!/usr/bin/env bash
set -euo pipefail

SERVICES=("$@")
if [ "${#SERVICES[@]}" -eq 0 ]; then
    SERVICES=("nginx" "gsx-backup.timer" "gsx-backup.service")
fi

printf "%-25s %-12s %-12s %-12s\n" "UNIT" "ACTIVE" "ENABLED" "FAILED"
printf "%-25s %-12s %-12s %-12s\n" "----" "------" "-------" "------"

for unit in "${SERVICES[@]}"; do
    active="$(systemctl is-active "$unit" 2>/dev/null || true)"
    enabled="$(systemctl is-enabled "$unit" 2>/dev/null || true)"
    if systemctl --quiet is-failed "$unit" 2>/dev/null; then failed="yes"; else failed="no"; fi
    printf "%-25s %-12s %-12s %-12s\n" "$unit" "$active" "$enabled" "$failed"
done

echo
echo "Timers:"
systemctl list-timers --all | grep -E 'gsx-backup|NEXT' || true
