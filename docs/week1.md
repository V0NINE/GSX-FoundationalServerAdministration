# Week 1 — Foundation and Remote Access

## Goal

The Week 1 goal is to transform a minimally installed Debian VM into a basic administrable server. The system must be reachable remotely, safely administrable through sudo, tracked in Git and reproducible through scripts.

## Current implementation

The current Week 1 implementation provides:

1. Basic package installation.
2. OpenSSH server installation and activation.
3. SSH configuration with two modes:
   - `bootstrap`: password authentication enabled temporarily.
   - `secure`: password authentication disabled, public-key login only.
4. Sudoers configuration for selected users.
5. Administrative directory structure under `/opt/gsx-admin`.
6. Backup directory under `/var/backups/gsx`.
7. Backup script using `tar`.
8. Verification script for the baseline setup.
9. Documentation for access, design decisions, troubleshooting and recovery.

## How to apply the configuration

From the VM:

```bash
cd scripts
chmod +x *.sh
sudo ./install_week1.sh --ssh-mode bootstrap --sudo-user gsx
```

The `bootstrap` mode is used first because it allows password login while SSH keys are being installed and tested.

After copying the public key to the server and verifying that key-based login works:

```bash
sudo ./configure_ssh_access.sh --mode secure
```

Then verify:

```bash
sudo ./verify_week1_setup.sh
```

## Why scripts?

Manual configuration is fragile. If the VM is lost or misconfigured, commands typed manually are hard to reproduce. Scripts provide:

- repeatability;
- easier review through Git;
- a clear record of decisions;
- a safer path to reinstall or recover;
- idempotence, because running scripts again should not damage the system.

## Deliverable checklist

| Requirement | Status | Evidence to add |
|---|---|---|
| Working Debian VM | Done | Screenshot/login command |
| Clean VM snapshot | Pending evidence | Snapshot name and screenshot |
| SSH installed and enabled | Done by script | `systemctl status ssh` |
| SSH access from host | Pending evidence | `ssh -p 2222 gsx@127.0.0.1` |
| Sudo configured | Done by script | `sudo whoami` |
| Git repository | Done | GitHub repository URL |
| Repository private | Must verify | GitHub visibility screenshot |
| Admin directory | Done by script | `ls -ld /opt/gsx-admin` |
| Setup scripts | Done | `scripts/` folder |
| Verification script | Done | `sudo ./verify_week1_setup.sh` |
| Backup script | Done | `/var/backups/gsx/*.tar.gz` |
| Documentation | Done | `docs/` folder |


