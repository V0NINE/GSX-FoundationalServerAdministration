# Final Troubleshooting Guide

## Purpose

This document consolidates common troubleshooting procedures across the full assignment.

## SSH does not work

Check service:

```bash
systemctl status ssh --no-pager
sudo sshd -t
```

Check configuration:

```bash
sudo cat /etc/ssh/sshd_config.d/50-gsx-custom.conf
```

If locked out from remote SSH, use the VirtualBox console and return to bootstrap mode:

```bash
sudo ./configure_ssh_access.sh --mode bootstrap
```

## Git push fails

If HTTPS asks for a password, use SSH authentication or a Personal Access Token.

Check remote:

```bash
git remote -v
```

SSH remote example:

```bash
git remote set-url origin git@github.com:<OWNER>/<REPO>.git
```

Test:

```bash
ssh -T git@github.com
```

## Nginx not responding

```bash
systemctl status nginx --no-pager
sudo nginx -t
journalctl -u nginx -n 50 --no-pager
curl -I http://localhost
```

Restart:

```bash
sudo systemctl restart nginx
```

## Backup timer not running

```bash
systemctl status gsx-week5-backup.timer --no-pager
systemctl list-timers --all | grep gsx-week5-backup
```

Fix:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now gsx-week5-backup.timer
```

## Backup fails

```bash
cd scripts/week5
sudo ./run_backup.sh /srv/greendev-data
journalctl -u gsx-week5-backup.service -n 80 --no-pager
```

Check that the backup disk is mounted:

```bash
findmnt /srv/greendev-data
mountpoint /srv/greendev-data
```

## Restore fails

```bash
cd scripts/week5
sudo ./verify_backup_integrity.sh /srv/greendev-data/backups/snapshots/latest
sudo ./test_restore.sh /srv/greendev-data
```

Check available space:

```bash
df -h /srv/greendev-data
```

## User cannot access a file

```bash
id <user>
ls -l <file>
ls -ld <directory>
getfacl <file>
getfacl <directory>
```

Common causes:

- user not in group;
- missing execute permission on parent directory;
- ACL mask too restrictive;
- user needs to log out/in after group change.

## Shared directory files do not inherit group

Check setgid:

```bash
ls -ld /home/greendevcorp/shared
```

Fix:

```bash
sudo chown root:greendevcorp /home/greendevcorp/shared
sudo chmod 3770 /home/greendevcorp/shared
sudo setfacl -d -m g:greendevcorp:rwx /home/greendevcorp/shared
```

## A process uses too much CPU

```bash
cd scripts/week3
./list_top_processes.sh cpu 10
./show_process_tree.sh <PID>
./process_metrics.sh <PID>
```

Decide whether to:

- wait;
- lower priority;
- stop gracefully;
- force kill.

## systemd service failed

```bash
systemctl --failed
systemctl status <service> --no-pager
journalctl -u <service> -n 80 --no-pager
```

Try:

```bash
sudo systemctl restart <service>
```

## NFS client cannot mount

On server:

```bash
systemctl status nfs-server --no-pager
sudo exportfs -v
```

On client:

```bash
command -v mount.nfs
ping -c 3 <SERVER_IP>
sudo mount -t nfs -o vers=4 <SERVER_IP>:/srv/greendev-data/shared /mnt/greendev-shared
```

If the client has no Internet, ensure VirtualBox has:

```text
Adapter 1: NAT
Adapter 2: Host-only
```

## Final recovery approach

If multiple things are broken, run weekly verifications in order:

```bash
sudo ./scripts/week2/verify_week2_setup.sh
sudo ./scripts/week3/verify_week3_setup.sh
sudo ./scripts/week4/verify_week4_setup.sh
sudo ./scripts/week5/verify_week5_setup.sh /srv/greendev-data
```

Then repair the first failing layer before continuing.
