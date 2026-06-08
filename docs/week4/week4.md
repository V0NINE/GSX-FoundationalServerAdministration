# Week 4 — Users, Groups and Access Control

## Goal

The goal of Week 4 is to create a secure collaborative environment for the GreenDevCorp development team.

The system must support four developers while enforcing least privilege:

- each developer has a private home directory;
- developers share team resources through a common group;
- shared files use controlled permissions;
- only authorized users can modify sensitive team files;
- per-user resource limits prevent accidental resource exhaustion;
- shell environment customization is applied consistently.

## Implemented components

Week 4 implements:

- group `greendevcorp`;
- users `dev1`, `dev2`, `dev3`, `dev4`;
- private home directories;
- shared team directory structure under `/home/greendevcorp`;
- POSIX permissions and ACLs;
- setgid and sticky bit on shared directories;
- `done.log` readable by the team and writable only by `dev1`;
- PAM limits for team users;
- shared shell environment in `/etc/profile.d/`;
- verification scripts.

## Relevant files

```text
scripts/week4/
├── setup_week4_tools.sh
├── add_developer.sh
├── setup_users_groups.sh
├── setup_team_directories.sh
├── setup_pam_limits.sh
├── setup_team_environment.sh
├── verify_access_control.sh
├── verify_resource_limits.sh
├── verify_week4_setup.sh
└── install_week4.sh

docs/
├── week4.md
├── users-groups-week4.md
├── permissions-acl-week4.md
├── resource-limits-week4.md
├── onboarding-week4.md
├── troubleshooting-week4.md
├── testing-evidence-week4.md
└── week4-reflection.md
```

## Setup procedure

From the repository:

```bash
chmod +x scripts/week4/*.sh
cd scripts/week4
sudo ./install_week4.sh
```

The installer runs:

1. `setup_week4_tools.sh`
2. `setup_users_groups.sh`
3. `setup_team_directories.sh`
4. `setup_pam_limits.sh`
5. `setup_team_environment.sh`
6. `verify_week4_setup.sh`

## Directory layout

```text
/home/greendevcorp/
├── bin
├── shared
└── done.log
```

### `/home/greendevcorp/bin`

Shared scripts for the team. Only members of `greendevcorp` can access it.

### `/home/greendevcorp/shared`

Shared work directory. It uses:

- `setgid` so new files inherit group `greendevcorp`;
- sticky bit so users cannot delete each other's files;
- ACLs to keep group access consistent.

### `/home/greendevcorp/done.log`

Team task log.

Policy:

- all team members can read it;
- only `dev1` can append entries;
- other users cannot write to it.

## Main verification

```bash
sudo ./verify_week4_setup.sh
```

Expected result:

```text
[+] Week 4 verification passed.
```



## Design summary

The design uses a Unix group to model the development team. Users are not given unnecessary administrative privileges. Shared access is granted through group permissions and ACLs instead of making files world-readable or world-writable.

This follows least privilege: each user gets the access required to work, but not more.
