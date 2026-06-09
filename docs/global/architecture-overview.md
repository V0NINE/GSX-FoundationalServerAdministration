# Architecture Overview

## Purpose

This document describes the final GreenDevCorp server architecture built during the assignment.

The system is a Debian-based server VM designed for foundational administration: secure access, service management, observability, user control, resource control, storage, backup and recovery.

## High-level architecture

```text
+-------------------------------------------------------------+
| Debian Server VM                                            |
|                                                             |
|  Access layer                                                |
|  - SSH                                                       |
|  - sudo                                                      |
|  - Git-managed scripts                                      |
|                                                             |
|  Service layer                                               |
|  - nginx.service                                             |
|  - systemd restart policy                                   |
|  - journald logs                                             |
|                                                             |
|  Automation layer                                            |
|  - gsx-backup.timer                                         |
|  - gsx-week5-backup.timer                                   |
|  - verification scripts                                     |
|                                                             |
|  User and access-control layer                               |
|  - users: dev1, dev2, dev3, dev4                            |
|  - group: greendevcorp                                      |
|  - private home directories                                 |
|  - shared directories, setgid, sticky bit, ACLs              |
|  - PAM limits                                                |
|                                                             |
|  Resource-control layer                                      |
|  - process diagnostics                                      |
|  - signal-aware workload                                    |
|  - gsx-workload.service                                     |
|  - CPUQuota, MemoryMax, TasksMax                            |
|                                                             |
|  Storage and backup layer                                    |
|  - /srv/greendev-data                                       |
|  - ext4 disk mounted by UUID                                |
|  - rsync snapshots                                          |
|  - SHA256 manifests                                         |
|  - restore tests                                             |
|                                                             |
|  Optional networked storage                                  |
|  - NFS export: /srv/greendev-data/shared                    |
+-------------------------------------------------------------+
```

## Main components

### SSH and sudo

SSH provides remote administration. Root login is disabled in secure mode, and administrative actions are performed through `sudo`.

### Git-managed infrastructure

Scripts and documentation are stored in Git so changes are reviewable and reproducible.

### Nginx service

Nginx is the example managed service. It is controlled by systemd and has a restart policy through a drop-in override.

### systemd timers

Timers automate recurring tasks:

- Week 2 administrative backup timer;
- Week 5 storage/backup timer.

### Observability

The system uses:

- `systemctl` for service state;
- `journalctl` for logs;
- custom scripts for status checks;
- verification scripts for weekly validation.

### Process and resource control

Week 3 adds scripts for process inspection, signal handling and cgroup/systemd resource limits.

### Users and groups

Week 4 models the development team:

```text
group: greendevcorp
users: dev1, dev2, dev3, dev4
```

Private home directories protect user data. Shared directories use group permissions, setgid, sticky bit and ACLs.

### Storage and backup

Week 5 adds a dedicated disk mounted at:

```text
/srv/greendev-data
```

Backups are stored as rsync snapshots with hard-link incrementals and SHA256 manifests.

### Optional NFS

NFS exports:

```text
/srv/greendev-data/shared
```

to a second VM for networked storage testing.

## Data flows

### SSH administration

```text
Admin host → SSH port forwarding / network → Debian VM → sudo
```

### Web service

```text
Client/local curl → nginx.service → journald logs
```

### Backup flow

```text
System data → rsync snapshot → /srv/greendev-data/backups/snapshots
             → SHA256SUMS → integrity verification
             → restore-tests
```

### NFS flow

```text
Client VM → host-only network → NFS server → /srv/greendev-data/shared
```

## Trust boundaries

| Boundary | Risk | Mitigation |
|---|---|---|
| SSH access | unauthorized login | key-based auth, no root login |
| sudo | excessive privileges | controlled sudoers |
| shared directories | accidental deletion | sticky bit, group policy |
| backups | false sense of safety | integrity checks and restore tests |
| NFS | network exposure | host-only network, restricted export CIDR |
| resource use | runaway processes | PAM limits and systemd cgroups |

## Operational model

The system is operated with:

- setup scripts;
- verification scripts;
- runbooks;
- Git commits;
- journal logs;
- documented design decisions.

