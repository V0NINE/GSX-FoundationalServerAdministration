# Week 1 Troubleshooting Guide

## SSH service is not running

Check:

```bash
systemctl status ssh
```

Start and enable it:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

Or re-run:

```bash
sudo ./setup_ssh_server.sh
```

## Cannot connect from host

Check the VirtualBox NAT port forwarding rule.

Expected host command:

```bash
ssh -p 2222 gsx@127.0.0.1
```

Inside the VM, check:

```bash
ip addr
sudo ss -tlnp | grep ':22'
systemctl status ssh
```

## SSH configuration invalid

Run:

```bash
sudo sshd -t
```

If it fails, check:

```bash
sudo nano /etc/ssh/sshd_config.d/50-gsx-custom.conf
```

Then restart:

```bash
sudo systemctl restart ssh
```

## Password login disabled too early

Use the VirtualBox console, log in locally and run:

```bash
cd scripts
sudo ./configure_ssh_access.sh --mode bootstrap
```

## User cannot use sudo

Check group membership:

```bash
groups gsx
```

Check sudoers files:

```bash
sudo ls -l /etc/sudoers.d
sudo visudo -c
```

Reapply:

```bash
sudo ./configure_sudoers.sh gsx
```

## Script says `require_root: command not found`

`require_root` is a Bash function defined in `script_message.sh`.

Fixes:

1. Make sure `script_message.sh` contains the `require_root` function.
2. Make sure the script sources it with:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/script_message.sh"
```

3. Run scripts with Bash, not `sh`:

```bash
sudo ./script_name.sh
```

Do not run:

```bash
sudo sh script_name.sh
```

## Backup fails

Check directory permissions:

```bash
ls -ld /var/backups/gsx
ls -ld /opt/gsx-admin/logs
```

Recreate baseline directories:

```bash
sudo ./setup_admin_dirs.sh
```

Then retry:

```bash
sudo ./backup_admin_data.sh
```

## Verify the full Week 1 baseline

```bash
sudo ./verify_week1_setup.sh
```

Repair safe baseline items:

```bash
sudo ./verify_week1_setup.sh --fix --ssh-mode bootstrap
```
