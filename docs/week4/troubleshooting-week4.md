# Week 4 Troubleshooting Guide

## User cannot access shared directory

Check group membership:

```bash
id dev2
```

Expected: `greendevcorp` appears in the group list.

If not:

```bash
sudo usermod -aG greendevcorp dev2
```

The user must log out and log back in for group membership to apply in a new session.

Check directory permissions:

```bash
ls -ld /home/greendevcorp/shared
getfacl /home/greendevcorp/shared
```

Expected mode: `3770`.

## User cannot read `done.log`

Check:

```bash
ls -l /home/greendevcorp/done.log
getfacl /home/greendevcorp/done.log
id dev2
```

Expected:

```text
-rw-r----- 1 dev1 greendevcorp ... done.log
```

The user must be a member of `greendevcorp`.

## User other than dev1 can write `done.log`

This violates the Week 4 policy.

Fix:

```bash
sudo chown dev1:greendevcorp /home/greendevcorp/done.log
sudo setfacl -b /home/greendevcorp/done.log
sudo chmod 0640 /home/greendevcorp/done.log
```

Verify:

```bash
sudo ./verify_access_control.sh
```

## `done.log` permissions check fails

If `stat` does not show `640`, check whether ACLs are modifying the effective mask:

```bash
getfacl /home/greendevcorp/done.log
```

For the current design, ACLs are not needed on `done.log`.

Reset:

```bash
sudo setfacl -b /home/greendevcorp/done.log
sudo chown dev1:greendevcorp /home/greendevcorp/done.log
sudo chmod 0640 /home/greendevcorp/done.log
```

## User does not receive `/home/greendevcorp/bin` in PATH

Check the profile script:

```bash
cat /etc/profile.d/greendevcorp.sh
```

Test with a login shell:

```bash
su - dev1 -s /bin/bash -c 'echo $PATH'
su - dev1 -s /bin/bash -c 'command -v done-add'
```

If it only fails with `runuser ... bash -c`, the test may not be using a login shell. `/etc/profile.d` is normally loaded by login shells.

## Shared files do not inherit group `greendevcorp`

Check setgid bit:

```bash
ls -ld /home/greendevcorp/shared
```

Expected mode includes `s` in the group execute position, for example:

```text
drwxrws--T
```

Fix:

```bash
sudo chown root:greendevcorp /home/greendevcorp/shared
sudo chmod 3770 /home/greendevcorp/shared
sudo setfacl -d -m g:greendevcorp:rwx /home/greendevcorp/shared
```

## One user can delete another user's shared file

Check sticky bit:

```bash
ls -ld /home/greendevcorp/shared
```

Expected mode: `3770`.

Fix:

```bash
sudo chmod 3770 /home/greendevcorp/shared
```

## PAM limits do not apply

Check configuration:

```bash
cat /etc/security/limits.d/90-greendevcorp.conf
```

Check PAM:

```bash
grep pam_limits.so /etc/pam.d/common-session
grep pam_limits.so /etc/pam.d/common-session-noninteractive
```

Test with login shell:

```bash
su - dev1 -s /bin/bash -c 'ulimit -n'
su - dev1 -s /bin/bash -c 'ulimit -u'
su - dev1 -s /bin/bash -c 'ulimit -v'
su - dev1 -s /bin/bash -c 'ulimit -t'
```

If limits do not apply, log out and start a new session.

## Full repair procedure

If the Week 4 setup is inconsistent, rerun:

```bash
cd scripts/week4
sudo ./setup_users_groups.sh
sudo ./setup_team_directories.sh
sudo ./setup_pam_limits.sh
sudo ./setup_team_environment.sh
sudo ./verify_week4_setup.sh
```

## Full verification

```bash
sudo ./verify_week4_setup.sh
```

Expected:

```text
[+] Week 4 verification passed.
```
