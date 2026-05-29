# Week 1 Backup Procedure

## Purpose

The Week 1 backup script creates an archive of the initial administrative configuration. This is not the final Week 5 backup strategy, but it provides a basic recovery mechanism for the first stage of the project.

## Backup script

Run:

```bash
sudo ./backup_admin_data.sh
```

The backup is stored in:

```text
/var/backups/gsx
```

The script backs up:

```text
/opt/gsx-admin
/etc/ssh/sshd_config
/etc/ssh/sshd_config.d
/etc/sudoers
/etc/sudoers.d
```

## Attribute preservation

The script uses `tar` options to preserve:

- permissions;
- numeric owners;
- ACLs;
- extended attributes.

This is important because configuration files and sudoers files depend on correct ownership and permissions.

## Verification

After creating the archive, the script checks that the tar file can be listed:

```bash
tar -tzf /var/backups/gsx/latest-week1-admin.tar.gz
```

## Restore test

To test without overwriting the real system:

```bash
mkdir -p /tmp/gsx-restore-test
sudo tar -xzf /var/backups/gsx/latest-week1-admin.tar.gz -C /tmp/gsx-restore-test
find /tmp/gsx-restore-test -maxdepth 3 -type f | head
```

## Limitations

This Week 1 backup is only a basic administrative backup. It does not replace a full disaster recovery plan. Week 5 will require a complete storage, backup and recovery strategy.
