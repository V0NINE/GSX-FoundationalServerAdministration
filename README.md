# GSX Practical Assignment 1 — Foundational Server Administration

## Project status

This repository contains the Week 1 baseline infrastructure for the GreenDevCorp Debian server used in the *Gestió de Sistemes i Xarxes* practical assignment.

The current objective is to make a minimal Debian VM administrable, repeatable and documented. The system is configured through scripts instead of manual one-off commands.

## Repository structure

```text
.
├── README.md
├── scripts/
│   ├── script_message.sh
│   ├── setup_basic_packages.sh
│   ├── setup_admin_dirs.sh
│   ├── setup_ssh_server.sh
│   ├── configure_ssh_access.sh
│   ├── configure_sudoers.sh
│   ├── backup_admin_data.sh
│   ├── verify_week1_setup.sh
│   └── install_week1.sh
└── docs/
    ├── week1.md
    ├── ssh-access.md
    ├── design-decisions.md
    ├── security-policy.md
    ├── backup-week1.md
    ├── troubleshooting-week1.md
    ├── reinstall-runbook.md
    ├── testing-evidence.md
    └── reflection-week1.md
```

## Quick start

Run these commands inside the Debian VM.

```bash
cd scripts
chmod +x *.sh

# First run: use bootstrap mode until SSH key login has been tested.
sudo ./install_week1.sh --ssh-mode bootstrap --sudo-user gsx
```

After confirming that key-based SSH login works from the host machine:

```bash
sudo ./configure_ssh_access.sh --mode secure
sudo ./verify_week1_setup.sh
```

## SSH access from host machine

With VirtualBox NAT port forwarding:

```bash
ssh -p 2222 gsx@127.0.0.1
```

Expected VirtualBox forwarding rule:

| Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
|---|---|---:|---:|---|---:|
| SSH | TCP | 127.0.0.1 | 2222 | empty/default | 22 |

## Week 1 deliverables

- Debian VM available locally.
- SSH server installed, enabled and reachable from the host.
- Sudo configured for administrative tasks.
- Git repository used to track scripts and documentation.
- Administrative directory structure created under `/opt/gsx-admin`.
- Backup directory created under `/var/backups/gsx`.
- Setup, verification and backup scripts included.
- Design choices and troubleshooting procedures documented.

## Important security note

This repository must be private. Do not commit passwords, private SSH keys, backup archives, VM images, logs containing secrets or personal data.
