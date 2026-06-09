# Week 5 Reflection

## What we learned

Week 5 focused on data durability. The most important lesson is that a backup is not useful until it has been verified and restored successfully.

Key lessons:

- adding storage requires partitioning, formatting and persistent mounts;
- `/etc/fstab` should use UUIDs instead of device names;
- backup automation must refuse unsafe conditions, such as an unmounted backup disk;
- rsync snapshots can reduce storage usage with hard links;
- integrity checks help detect corrupted backups;
- restore tests are essential;
- NFS demonstrates networked storage but still depends on Unix permissions.

## Most challenging part

The most challenging part was making storage and networked storage reliable in a VM environment.

Common issues included:

- identifying the correct disk;
- avoiding formatting the system disk;
- ensuring the backup disk was mounted;
- making `/etc/fstab` match the mount point exactly;
- configuring VirtualBox NAT plus host-only networking for NFS.

## Design decisions

### Why a separate disk?

Because backups should not be stored only on the same filesystem as the live data. A separate disk improves separation and demonstrates storage expansion.

### Why ext4?

ext4 is stable, common on Debian and appropriate for this lab.

### Why rsync snapshots?

They are simple to inspect, easy to restore and efficient when files do not change.

### Why SHA256 manifests?

They provide a way to verify that backup files can still be read and match the recorded checksums.

### Why restore to an alternate location?

Because restore procedures should be tested without risking live data.

### Why NFS as optional network storage?

NFS is a standard Unix/Linux network filesystem and is appropriate for demonstrating shared storage across VMs.

## What we would improve

Future improvements:

- remote/offsite backup copy;
- encryption at rest;
- backup alerts;
- backup dashboard;
- LVM snapshots;
- automatic retention cleanup through systemd timer;
- backup of databases using database-aware tools;
- NFS authentication/hardening;
- monitoring disk usage.

