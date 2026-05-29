# Week 1 Security Policy

## Scope

This document defines the initial security rules for the Debian VM in Week 1.

## User access

- Normal administration is performed as user `gsx`.
- Administrative privileges are escalated using `sudo`.
- Direct SSH login as root is not allowed in secure mode.

## SSH policy

Final SSH policy:

```text
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Temporary bootstrap policy:

```text
PermitRootLogin prohibit-password
PasswordAuthentication yes
PubkeyAuthentication yes
```

Bootstrap mode is only used until key-based authentication is working.

## Password and key handling

Do not commit the following to Git:

- passwords;
- private keys;
- `.env` files;
- backup files;
- VM disks or ISO images;
- logs containing sensitive data.

Public keys may be documented only if necessary, but private keys must never be included.

## Repository visibility

The GitHub repository must be private because it contains infrastructure details and could later contain sensitive configuration patterns.

## Least privilege

The system should grant only the privileges needed:

- regular work as normal user;
- administrative actions through `sudo`;
- shared admin directories owned by root and an admin group;
- backups restricted to root/admin group.

## Emergency recovery

If SSH secure mode causes lockout, use the VirtualBox console and re-enable bootstrap mode:

```bash
sudo ./configure_ssh_access.sh --mode bootstrap
```
