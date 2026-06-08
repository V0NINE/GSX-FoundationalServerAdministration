# Week 4 Onboarding Guide

## Purpose

This guide explains how to add a new developer to the GreenDevCorp server.

The current Week 4 model has users:

```text
dev1
dev2
dev3
dev4
```

The team group is:

```text
greendevcorp
```

## Add a new developer

Example: add `dev5`.

```bash
cd scripts/week4
sudo ./add_developer.sh dev5
```

This script:

- creates the user if it does not exist;
- locks the password by default;
- adds the user to `greendevcorp`;
- creates a private home directory;
- sets home directory permissions to `0700`.

## Verify the new user

```bash
id dev5
ls -ld /home/dev5
```

Expected:

- `dev5` belongs to `greendevcorp`;
- `/home/dev5` exists;
- home directory is private.

## SSH access

The script does not automatically configure SSH keys.

To enable SSH login for the new user, create:

```text
/home/dev5/.ssh/authorized_keys
```

with correct ownership and permissions:

```bash
sudo mkdir -p /home/dev5/.ssh
sudo nano /home/dev5/.ssh/authorized_keys
sudo chown -R dev5:dev5 /home/dev5/.ssh
sudo chmod 700 /home/dev5/.ssh
sudo chmod 600 /home/dev5/.ssh/authorized_keys
```

## Shared resources

After login, the user should be able to access:

```text
/home/greendevcorp/shared
/home/greendevcorp/bin
```

If the login shell loads `/etc/profile.d/greendevcorp.sh`, the user will also receive:

```text
GREENDEVCORP_HOME
GREENDEVCORP_SHARED
/home/greendevcorp/bin in PATH
```

Test:

```bash
su - dev5 -s /bin/bash -c 'echo $GREENDEVCORP_SHARED'
su - dev5 -s /bin/bash -c 'command -v done-add'
```

## Access policy

A new developer should:

- have a private home directory;
- be able to read shared team files;
- be able to create files in the shared directory;
- not be able to delete files owned by other developers in the sticky shared directory;
- not be able to write to `done.log` unless explicitly authorized.

## Authorizing another user to write `done.log`

The current policy allows only `dev1` to write `done.log`.

If requirements change and another user should also write to it, use ACLs or create a dedicated writer group.

Example ACL approach:

```bash
sudo setfacl -m u:dev5:rw /home/greendevcorp/done.log
```

However, this changes the security model and must be documented.

## Offboarding a developer

If a developer leaves:

1. lock the account:

```bash
sudo passwd -l dev5
```

2. remove active sessions:

```bash
who
sudo pkill -KILL -u dev5
```

3. remove from team group:

```bash
sudo gpasswd -d dev5 greendevcorp
```

4. archive or transfer home directory if needed:

```bash
sudo tar -czf /var/backups/gsx/dev5-home-archive.tar.gz /home/dev5
```

5. disable SSH keys:

```bash
sudo mv /home/dev5/.ssh/authorized_keys /home/dev5/.ssh/authorized_keys.disabled
```

6. document the action.

Do not delete user data before confirming retention requirements.
