# Week 4 Per-User Resource Limits

## Purpose

Per-user resource limits protect the server from accidental resource exhaustion.

If one developer starts too many processes, opens too many files or consumes too much memory, limits reduce the chance that the whole server becomes unusable.

## Mechanism

Week 4 uses PAM limits.

Configuration file:

```text
/etc/security/limits.d/90-greendevcorp.conf
```

PAM module:

```text
pam_limits.so
```

The module should be enabled in:

```text
/etc/pam.d/common-session
/etc/pam.d/common-session-noninteractive
```

## Configured limits

Example configuration:

```text
@greendevcorp soft nofile 1024
@greendevcorp hard nofile 2048

@greendevcorp soft nproc 100
@greendevcorp hard nproc 150

@greendevcorp soft as 524288
@greendevcorp hard as 786432

@greendevcorp soft cpu 10
@greendevcorp hard cpu 15
```

## Meaning

| Limit | Meaning |
|---|---|
| `nofile` | maximum number of open files |
| `nproc` | maximum number of processes/tasks |
| `as` | virtual address space limit in KB |
| `cpu` | CPU time limit |

## Soft vs hard limits

| Type | Meaning |
|---|---|
| soft | current effective limit |
| hard | maximum value the user can raise the soft limit to |

A normal user can lower their soft limit or raise it up to the hard limit, but cannot exceed the hard limit.

## Check limits for a user

Use:

```bash
sudo ./verify_resource_limits.sh dev1
```

Manual check:

```bash
su - dev1 -s /bin/bash -c "ulimit -n"
su - dev1 -s /bin/bash -c "ulimit -u"
su - dev1 -s /bin/bash -c "ulimit -v"
su - dev1 -s /bin/bash -c "ulimit -t"
```

## Important note about CPU time

The `cpu` limit may be displayed differently by `ulimit -t` depending on shell and PAM behavior. The important part for Week 4 is that a finite CPU time limit is applied to the developer session.

## Why PAM limits?

PAM limits apply at login/session creation. That makes them useful for users who log in through SSH or a shell session.

This is different from Week 3 systemd service limits, which apply to a specific systemd unit.

## PAM limits vs systemd cgroups

| Feature | PAM limits | systemd/cgroups |
|---|---|---|
| Main target | user sessions | services |
| Config location | `/etc/security/limits.d/` | unit files |
| Example | `nproc`, `nofile` | `CPUQuota`, `MemoryMax` |
| Best for | login users | daemons/services |

Both are useful, but they solve different problems.

## Verification

Run:

```bash
sudo ./verify_resource_limits.sh dev1
```

Expected result:

```text
[+] Resource-limits verification passed.
```

Then run the full verification:

```bash
sudo ./verify_week4_setup.sh
```
