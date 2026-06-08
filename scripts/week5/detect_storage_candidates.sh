#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../script_message.sh" ]; then
    source "$SCRIPT_DIR/../script_message.sh"
else
    output_message() {
        local level="${1:-INFO}"
        shift || true
        echo "[$level] $*"
    }
    require_root() {
        if [ "${EUID}" -ne 0 ]; then
            echo "[ERROR] This script must be run as root. Use sudo." >&2
            exit 1
        fi
    }
fi

# detect_storage_candidates.sh - Show disks that may be usable for Week 5 storage
#
# USAGE:
#   ./detect_storage_candidates.sh
#
# This script is read-only. It does not modify disks.

output_message INFO "Block devices:"
lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS,MODEL,SERIAL

echo
output_message INFO "Candidate whole disks without mounted partitions:"
while read -r name type size fstype mountpoints; do
    if [ "$type" = "disk" ]; then
        dev="/dev/$name"
        children="$(lsblk -nr -o NAME "$dev" | tail -n +2 | wc -l)"
        mounted_children="$(lsblk -nr -o MOUNTPOINTS "$dev" | tail -n +2 | grep -vc '^$' || true)"
        if [ "$children" -eq 0 ] || [ "$mounted_children" -eq 0 ]; then
            echo "  $dev"
        fi
    fi
done < <(lsblk -nr -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS)

echo
output_message WARNING "Choose the new VirtualBox disk carefully. Do not format the system disk."
