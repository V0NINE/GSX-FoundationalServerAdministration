# GSX — Foundational Server Administration

## Project overview

This repository contains the practical implementation for *Gestió de Sistemes i Xarxes — Practical Assignment 1: Foundational Server Administration*.

The project simulates the infrastructure of GreenDevCorp, a small startup that needs a Debian server prepared for secure remote administration, service management, user collaboration, resource control, storage expansion, backups and recovery.

The final system is designed to be:

- usable;
- reliable;
- observable;
- repeatable;
- documented;

## Repository structure

```text
.
├── README.md
├── scripts/
│   ├── week2/
│   ├── week3/
│   ├── week4/
│   └── week5/
├── systemd/
│   ├── week3/
│   └── week5/
└── docs/
    ├── week1.md
    ├── week2.md
    ├── week3.md
    ├── week4.md
    ├── week5.md
    ├── architecture-overview.md
    ├── configuration-manual.md
    ├── operational-runbooks.md
    ├── troubleshooting-guide.md
    ├── final-security-policy.md
    ├── production-readiness-checklist.md
    ├── design-rationale.md
    ├── final-verification-evidence.md
    ├── interview-prep.md
    └── final-reflection.md
```

## Weekly scope

| Week | Scope |
|---|---|
| Week 0 | Debian VM installation and clean snapshot |
| Week 1 | SSH, sudo, Git and baseline automation |
| Week 2 | Nginx, systemd services, timers and logs |
| Week 3 | Process inspection, signals and resource limits |
| Week 4 | Users, groups, permissions, ACLs and PAM limits |
| Week 5 | Storage, backup, restore and optional NFS |
| Week 6 | Final documentation, verification and reflection |

## Final architecture summary

The final system includes:

- Debian server VM;
- secure SSH administration;
- Git-managed scripts and documentation;
- Nginx managed by systemd;
- automated backup timers;
- journald logging and retention;
- process and resource-control demonstrations;
- developer users and group-based access control;
- dedicated data/backup disk mounted at `/srv/greendev-data`;
- rsync snapshot backups;
- backup integrity verification;
- restore tests;
- optional NFS shared storage.

## Main setup flow

A new sysadmin should follow:

```bash
git clone <REPOSITORY_URL>
cd GSX-FoundationalServerAdministration
```

Then apply the week-specific setup scripts in order, following:

```text
docs/configuration-manual.md
```

## Final verification

Minimum verification commands:

```bash
sudo ./scripts/week2/verify_week2_setup.sh
sudo ./scripts/week3/verify_week3_setup.sh
sudo ./scripts/week4/verify_week4_setup.sh
sudo ./scripts/week5/verify_week5_setup.sh /srv/greendev-data
```

