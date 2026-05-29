# Week 1 Design Decisions

## SSH for remote access

SSH was chosen because it is the standard Linux tool for secure remote administration. It provides encrypted communication, user authentication and integration with public-key login.

Alternatives such as VirtualBox console access are useful for emergency recovery, but not for daily administration. Console-only administration is harder to automate and does not represent a realistic server workflow.

## Bootstrap mode before secure mode

The SSH configuration supports two modes:

- `bootstrap`: password authentication enabled.
- `secure`: password authentication disabled.

This is a safety decision. If password login is disabled before the SSH public key is correctly installed, administrators can lock themselves out. Bootstrap mode allows initial access, while secure mode is the intended final configuration.

## Disabling root SSH login

Root login over SSH is disabled in secure mode. Administrative access should go through a normal user plus `sudo`.

Reasons:

- better accountability;
- less exposure of the root account;
- compatibility with least-privilege principles;
- easier auditing of administrative actions.

## Sudo instead of direct root use

`sudo` allows a normal user to perform administrative tasks only when needed. This reduces the amount of time spent as root and avoids routine work being done with unlimited privileges.

## Git for infrastructure tracking

Git is used to track scripts, configuration templates and documentation. This makes changes reviewable and reversible.

The repository should contain:

- setup scripts;
- verification scripts;
- documentation;
- non-secret configuration templates;
- design notes.

The repository must not contain:

- passwords;
- private SSH keys;
- VM images;
- backup archives;
- large logs;
- files with personal or sensitive data.

## Administrative directory structure

The directory `/opt/gsx-admin` is used as the local administrative workspace.

Suggested structure:

```text
/opt/gsx-admin/
├── scripts
├── configs
├── docs
└── logs
```

Backups are stored under:

```text
/var/backups/gsx
```

Reasoning:

- `/opt` is appropriate for locally managed operational tooling.
- `/var/backups` is appropriate for generated backup data.
- separating scripts, configs, docs and logs keeps the system understandable.

## Idempotent scripts

Scripts are designed to be safe to run multiple times. For example:

- existing packages are not reinstalled manually;
- existing directories are reused;
- SSH configuration is only rewritten if needed;
- verification can be run repeatedly.

This matters because infrastructure automation should converge the machine toward the desired state instead of breaking when repeated.

## Trade-offs

### Simplicity vs. full configuration management

The current solution uses Bash scripts instead of tools such as Ansible. Bash is simpler for this assignment stage and easier to inspect directly, but Ansible would scale better for many machines.

### NAT port forwarding vs. bridged networking

NAT with port forwarding is easy and predictable on student laptops. Bridged networking can be more realistic but may fail on some networks or require extra configuration.

### Password login during bootstrap

Allowing passwords temporarily is less secure than key-only login, but it avoids lockout during first setup. The final secure state should be key-only login.
