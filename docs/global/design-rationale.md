# Design Rationale

## Purpose

This document explains why the main technical choices were made.

## Why Debian?

Debian is stable, well-documented and appropriate for server administration training. It uses standard Linux tools and systemd.

## Why SSH?

SSH is the standard secure remote administration protocol for Linux systems. It avoids relying on the VirtualBox console for normal administration.

## Why key-based SSH?

Key-based authentication reduces password brute-force risk and supports disabling password authentication.

## Why disable root SSH login?

Root is too powerful to expose directly. Using a normal user plus sudo provides better accountability and follows least privilege.

## Why Git?

Git provides version history, reviewability and rollback for scripts and documentation. Infrastructure changes should be tracked like code.

## Why Bash scripts instead of Ansible?

Bash is simple and appropriate for a small single-server lab. It exposes the underlying Linux commands clearly.

Trade-off: Bash does not scale as well as Ansible for many servers.

## Why Nginx?

Nginx is a common web server and a good example service for systemd management, logs and restart behavior.

## Why systemd timers?

systemd timers integrate with systemd services and logs. They make scheduled jobs observable with `systemctl` and `journalctl`.

## Why journald?

journald is the default structured logging system for systemd services. It allows service-specific log inspection.

## Why process demos?

A custom workload allows safe demonstration of CPU usage, process trees and signals without harming real services.

## Why systemd resource controls?

systemd resource controls are declarative, repeatable and enforced by cgroups. They are appropriate for limiting services.

## Why Unix groups for developers?

Groups are the standard Unix model for shared permissions. Adding a user to a group is simpler and more scalable than managing individual permissions everywhere.

## Why setgid and sticky bit?

setgid ensures new files in shared directories inherit the team group. The sticky bit prevents users from deleting each other's files in a writable shared directory.

## Why PAM limits?

PAM limits apply to user sessions and reduce the risk of one developer exhausting system resources.

## Why a separate storage disk?

A separate disk demonstrates real storage administration and reduces coupling between system disk and data/backup storage.

## Why mount by UUID?

Device names like `/dev/sdb1` can change. UUIDs are persistent and safer for `/etc/fstab`.

## Why rsync snapshots?

rsync snapshots are easy to inspect, easy to restore and efficient with `--link-dest`.

## Why SHA256 manifests?

Checksums prove files can be read and match the state recorded at backup time.

## Why restore tests?

A backup that has never been restored is unproven. Restore tests reduce false confidence.

## Why optional NFS?

NFS demonstrates networked storage between VMs and introduces real sysadmin issues such as network configuration, exports and Unix permissions.

## Main trade-offs

| Choice | Benefit | Trade-off |
|---|---|---|
| Bash scripts | simple, transparent | less scalable |
| NAT + host-only networking | reliable lab setup | less realistic than routed networks |
| rsync snapshots | easy restore | local-only unless replicated |
| ext4 | stable and simple | no advanced volume management |
| NFS optional | realistic network storage | needs second VM and network setup |
| PAM limits | protects user sessions | not the same as service cgroups |
