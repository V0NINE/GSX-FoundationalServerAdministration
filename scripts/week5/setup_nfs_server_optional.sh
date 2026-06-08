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

# setup_nfs_server_optional.sh - Optional NFS server for shared Week 5 storage
#
# USAGE:
#   sudo ./setup_nfs_server_optional.sh [/srv/greendev-data/shared] [client_cidr]
#
# EXAMPLE:
#   sudo ./setup_nfs_server_optional.sh /srv/greendev-data/shared 192.168.56.0/24
#
# This is optional for Week 5.

require_root

EXPORT_DIR="${1:-/srv/greendev-data/shared}"
CLIENT_CIDR="${2:-192.168.56.0/24}"

apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y nfs-kernel-server

mkdir -p "$EXPORT_DIR"
if getent group greendevcorp >/dev/null; then
    chown root:greendevcorp "$EXPORT_DIR"
    chmod 2770 "$EXPORT_DIR"
fi

EXPORT_LINE="$EXPORT_DIR $CLIENT_CIDR(rw,sync,no_subtree_check)"

if grep -q "^$EXPORT_DIR " /etc/exports; then
    cp /etc/exports "/etc/exports.bak.$(date +%Y%m%d-%H%M%S)"
    sed -i "\#^$EXPORT_DIR #d" /etc/exports
fi

echo "$EXPORT_LINE" >> /etc/exports
exportfs -ra
systemctl enable --now nfs-server

output_message SUCCESS "NFS export configured:"
exportfs -v | grep "$EXPORT_DIR" || true
