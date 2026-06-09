# Week 5 Storage Layout and Capacity Planning

## Purpose

This document explains the Week 5 storage setup.

The startup's data is growing, so a new disk is added to the VM instead of keeping all data on the original root disk.

## VirtualBox disk

A new virtual disk was added in VirtualBox:

```text
VirtualBox → VM Settings → Storage → Add Hard Disk
```

Recommended lab size:

```text
10–20 GB
```

The new disk is usually detected as:

```text
/dev/sdb
```

Always confirm with:

```bash
lsblk -f
./detect_storage_candidates.sh
```

## Partitioning and filesystem

The script `setup_storage_disk.sh` creates:

- GPT partition table;
- one primary partition;
- ext4 filesystem;
- filesystem label `GSXDATA`.

Example command:

```bash
sudo ./setup_storage_disk.sh /dev/sdb /srv/greendev-data
```

## Mount point

The disk is mounted at:

```text
/srv/greendev-data
```

This path is used because `/srv` is appropriate for service data provided by the system.

## Persistent mount

The mount is made persistent through `/etc/fstab` using the partition UUID.

Example:

```text
UUID=<uuid> /srv/greendev-data ext4 defaults,nofail 0 2
```

Using UUID is better than `/dev/sdb1` because device names can change between boots.

## Verification commands

```bash
lsblk -f
findmnt /srv/greendev-data
grep /srv/greendev-data /etc/fstab
df -h /srv/greendev-data
```

Expected:

- the filesystem is ext4;
- `/srv/greendev-data` is mounted;
- `/etc/fstab` contains the mount;
- `df -h` shows the new disk capacity.

## Directory structure

```text
/srv/greendev-data/
├── backups/
│   └── snapshots/
├── restore-tests/
└── shared/
```

### `/srv/greendev-data/backups`

Stores backup snapshots.

### `/srv/greendev-data/restore-tests`

Stores test restores. This prevents accidental overwriting of live data.

### `/srv/greendev-data/shared`

Optional shared storage directory, used by NFS in the optional part.

## Capacity planning

The first version of this lab uses a small virtual disk, but the same design can scale by:

- increasing the VirtualBox disk size;
- adding another disk;
- using LVM in a future iteration;
- moving backups to another VM or remote storage;
- rotating old snapshots using retention policies.

