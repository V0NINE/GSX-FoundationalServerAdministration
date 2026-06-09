# Final Security Policy

## Purpose

This document defines the final security rules for the GreenDevCorp server.

## Repository policy

The GitHub repository must remain private.

Do not commit:

- private SSH keys;
- passwords;
- tokens;
- backup archives;
- VM disks;
- ISO images;
- sensitive logs;
- personal data.

## SSH policy

Final SSH policy:

```text
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Temporary bootstrap mode may allow password login only while SSH keys are being installed and tested.

## Root access

Direct root SSH login is not allowed.

Administrative actions should be performed with:

```bash
sudo <command>
```

## User policy

Developer users:

```text
dev1
dev2
dev3
dev4
```

Team group:

```text
greendevcorp
```

Rules:

- developers do not receive sudo by default;
- home directories are private;
- shared access is granted through the group;
- sensitive files are writable only by authorized users.

## File permissions

Private home directories:

```text
/home/devX → 0700
```

Shared directory:

```text
/home/greendevcorp/shared → 3770
```

This uses:

- setgid for group inheritance;
- sticky bit to prevent users deleting each other's files.

Task log:

```text
/home/greendevcorp/done.log
owner: dev1
group: greendevcorp
mode: 0640
```

## Resource limits

Developer sessions receive PAM limits for:

- open files;
- number of processes;
- memory/address space;
- CPU time.

Services can use systemd/cgroup limits such as:

```text
CPUQuota
MemoryMax
TasksMax
```

## Logging policy

Service logs are inspected with:

```bash
journalctl
```

journald retention is configured to prevent unlimited log growth.

## Backup policy

Backups must be:

- automated;
- verified;
- restorable;
- documented.

Backups are stored under:

```text
/srv/greendev-data/backups/snapshots
```

Each snapshot includes a SHA256 manifest.

## NFS policy

NFS is optional and should be limited to the host-only lab network:

```text
192.168.56.0/24
```

NFS should not be exposed publicly.

## Offboarding policy

When a developer leaves:

1. lock account;
2. remove active sessions;
3. remove from group;
4. disable SSH keys;
5. archive data if needed;
6. document action.

## Incident response basics

If compromise is suspected:

1. disconnect network if necessary;
2. preserve logs;
3. rotate SSH keys;
4. lock affected accounts;
5. verify backups;
6. restore from known-good backup if needed;
7. document the incident.
