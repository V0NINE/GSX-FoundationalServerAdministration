# Week 4 Permissions, setgid, Sticky Bit and ACLs

## Purpose

This document explains the Week 4 permission model for shared team resources.

The goal is to allow collaboration without making files insecure.

## Directory structure

```text
/home/greendevcorp/
├── bin
├── shared
└── done.log
```

Check:

```bash
ls -ld /home/greendevcorp /home/greendevcorp/bin /home/greendevcorp/shared
ls -l /home/greendevcorp/done.log
```

## `/home/greendevcorp`

Expected mode:

```text
2750
```

Meaning:

| Part | Meaning |
|---|---|
| `2` | setgid bit |
| `7` | owner can read/write/execute |
| `5` | group can read/execute |
| `0` | others have no access |

The setgid bit helps preserve group ownership inside the team area.

## `/home/greendevcorp/bin`

Expected mode:

```text
2750
```

This directory stores shared team scripts.

Only root or authorized administrators should modify scripts here. Team members can execute scripts if they have access.

## `/home/greendevcorp/shared`

Expected mode:

```text
3770
```

Meaning:

| Bit | Meaning |
|---|---|
| `2` / setgid | new files inherit group `greendevcorp` |
| `1` / sticky bit | users cannot delete files owned by other users |
| `770` | owner and group have full access; others have none |

This is appropriate for a shared work directory because team members can collaborate, but one developer cannot delete another developer's files.

## setgid on directories

When setgid is applied to a directory, new files created inside inherit the directory group.

Example:

```bash
sudo -u dev2 touch /home/greendevcorp/shared/test.txt
ls -l /home/greendevcorp/shared/test.txt
```

Expected group:

```text
greendevcorp
```

## Sticky bit

The sticky bit prevents users from deleting or renaming files they do not own, even if the directory is writable.

This is useful in shared writable directories.

Example policy:

- `dev2` can create a file in `shared`;
- `dev3` can access the shared directory;
- `dev3` must not be able to delete `dev2`'s file.

## POSIX ACLs

ACLs are used on the shared directory to make group access more explicit and consistent.

Check:

```bash
getfacl /home/greendevcorp/shared
```

Expected idea:

```text
group:greendevcorp:rwx
default:group:greendevcorp:rwx
```

Default ACLs apply permissions to newly created files and directories.

## `done.log`

The task log is:

```text
/home/greendevcorp/done.log
```

Policy:

- `dev1` can write;
- all `greendevcorp` members can read;
- other users have no access.

Implementation:

```text
owner: dev1
group: greendevcorp
mode: 0640
```

Expected:

```text
-rw-r----- 1 dev1 greendevcorp ... /home/greendevcorp/done.log
```

ACLs are not required for this file because normal Unix ownership is enough:

| Entity | Permission |
|---|---|
| `dev1` owner | read/write |
| `greendevcorp` group | read |
| others | none |

## Helper script: `done-add`

The helper script is:

```text
/home/greendevcorp/bin/done-add
```

It allows only `dev1` to add entries to `done.log`.

Usage as `dev1`:

```bash
done-add "Completed backup verification"
```

If `dev2` runs it, it should fail.

## Verification

Run:

```bash
sudo ./verify_access_control.sh
```

Important expected results:

- `dev1` can append to `done.log`;
- `dev2` can read `done.log`;
- `dev2` cannot append to `done.log`;
- files in `shared` inherit group `greendevcorp`;
- sticky bit prevents `dev3` from deleting `dev2`'s file.
