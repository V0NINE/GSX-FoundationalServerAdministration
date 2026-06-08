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

# setup_storage_disk.sh - Partition, format and mount a new Week 5 data disk
#
# USAGE:
#   sudo ./setup_storage_disk.sh /dev/sdX [/srv/greendev-data]
#
# EXAMPLE:
#   sudo ./setup_storage_disk.sh /dev/sdb /srv/greendev-data
#
# WARNING:
#   This script destroys data on the device passed as first argument.
#   Only use it with the new empty VirtualBox disk created for Week 5.

require_root

DEVICE="${1:-}"
MOUNT_POINT="${2:-/srv/greendev-data}"
FS_LABEL="GSXDATA"

if [ -z "$DEVICE" ]; then
    output_message ERROR "USAGE: $0 /dev/sdX [/srv/greendev-data]"
    exit 1
fi

if [ ! -b "$DEVICE" ]; then
    output_message ERROR "$DEVICE is not a block device."
    exit 1
fi

ROOT_DEVICE="$(findmnt -no SOURCE / | sed 's/[0-9]*$//')"
if [ "$DEVICE" = "$ROOT_DEVICE" ]; then
    output_message ERROR "$DEVICE appears to be the root/system disk. Refusing to continue."
    exit 1
fi

if lsblk -nr -o MOUNTPOINTS "$DEVICE" | grep -q '/'; then
    output_message ERROR "$DEVICE or one of its partitions is currently mounted. Refusing to continue."
    lsblk "$DEVICE"
    exit 1
fi

if lsblk -nr -o NAME "$DEVICE" | tail -n +2 | grep -q .; then
    output_message WARNING "$DEVICE already has partitions:"
    lsblk "$DEVICE"
    read -r -p "Type FORMAT to destroy existing partition table and continue: " CONFIRM
else
    read -r -p "This will partition and format $DEVICE. Type FORMAT to continue: " CONFIRM
fi

if [ "$CONFIRM" != "FORMAT" ]; then
    output_message ERROR "Confirmation failed. Aborting."
    exit 1
fi

output_message INFO "Creating GPT partition table on $DEVICE..."
parted -s "$DEVICE" mklabel gpt
parted -s "$DEVICE" mkpart primary ext4 1MiB 100%

partprobe "$DEVICE"
sleep 2

PARTITION="$(lsblk -nr -o PATH "$DEVICE" | tail -n 1)"

if [ -z "$PARTITION" ] || [ "$PARTITION" = "$DEVICE" ]; then
    output_message ERROR "Could not detect created partition."
    lsblk "$DEVICE"
    exit 1
fi

output_message INFO "Formatting $PARTITION as ext4..."
mkfs.ext4 -F -L "$FS_LABEL" "$PARTITION"

UUID="$(blkid -s UUID -o value "$PARTITION")"
if [ -z "$UUID" ]; then
    output_message ERROR "Could not read UUID for $PARTITION."
    exit 1
fi

mkdir -p "$MOUNT_POINT"

FSTAB_LINE="UUID=$UUID $MOUNT_POINT ext4 defaults,nofail 0 2"

if grep -q " $MOUNT_POINT " /etc/fstab; then
    output_message WARNING "Removing existing fstab entry for $MOUNT_POINT."
    cp /etc/fstab "/etc/fstab.bak.$(date +%Y%m%d-%H%M%S)"
    sed -i "\# $MOUNT_POINT #d" /etc/fstab
fi

echo "$FSTAB_LINE" >> /etc/fstab

output_message INFO "Mounting $MOUNT_POINT..."
mount "$MOUNT_POINT"

mkdir -p "$MOUNT_POINT/backups/snapshots" "$MOUNT_POINT/restore-tests" "$MOUNT_POINT/shared"
chown root:root "$MOUNT_POINT"
chmod 0755 "$MOUNT_POINT"

if getent group greendevcorp >/dev/null; then
    chown root:greendevcorp "$MOUNT_POINT/shared"
    chmod 2770 "$MOUNT_POINT/shared"
    setfacl -m g:greendevcorp:rwx "$MOUNT_POINT/shared"
    setfacl -d -m g:greendevcorp:rwx "$MOUNT_POINT/shared"
fi

output_message SUCCESS "Storage disk configured."
lsblk -f "$DEVICE"
findmnt "$MOUNT_POINT"
