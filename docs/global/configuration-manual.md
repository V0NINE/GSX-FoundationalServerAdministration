# Configuration Manual

## Purpose

This manual explains how to rebuild the system from a clean Debian VM.

It is intended for another sysadmin taking over the project.

## Prerequisites

- Debian VM installed.
- User `gsx` exists.
- Internet access.
- Git available or installable.
- Repository access.
- VirtualBox available for disk and network configuration.

## Step 0 — Clean VM snapshot

After the initial Debian installation, create a clean snapshot in VirtualBox:

```text
week0-clean
```

This allows rollback before applying infrastructure changes.

## Step 1 — Clone repository

```bash
sudo apt update
sudo apt install -y git sudo
git clone <REPOSITORY_URL>
cd GSX-FoundationalServerAdministration
```

## Step 2 — Week 1 baseline

Run the Week 1 setup according to the repository scripts.

Typical flow:

```bash
cd scripts
chmod +x *.sh
sudo ./install_week1.sh --ssh-mode bootstrap --sudo-user gsx
```

Configure SSH keys from the host. After key-based login works:

```bash
sudo ./configure_ssh_access.sh --mode secure
```

Verify:

```bash
sudo ./verify_week1_setup.sh
```

## Step 3 — Week 2 services and observability

```bash
cd scripts/week2
chmod +x *.sh
sudo ./install_week2.sh
```

Verify:

```bash
sudo ./verify_week2_setup.sh
```

Expected:

- Nginx active;
- Nginx enabled;
- backup timer active;
- journald retention configured.

## Step 4 — Week 3 process and resource control

```bash
cd scripts/week3
chmod +x *.sh
sudo ./install_week3.sh
```

Start and test the workload service if needed:

```bash
sudo systemctl start gsx-workload.service
sudo ./test_resource_limits.sh
```

Verify:

```bash
sudo ./verify_week3_setup.sh
```

## Step 5 — Week 4 users and access control

```bash
cd scripts/week4
chmod +x *.sh
sudo ./install_week4.sh
```

Verify:

```bash
sudo ./verify_week4_setup.sh
```

Expected:

- group `greendevcorp` exists;
- users `dev1`–`dev4` exist;
- home directories are private;
- shared directory permissions work;
- PAM limits apply.

## Step 6 — Week 5 storage

Power off the VM and add a new disk in VirtualBox.

Recommended size:

```text
10–20 GB
```

Boot the VM and detect the disk:

```bash
cd scripts/week5
chmod +x *.sh
sudo ./setup_week5_tools.sh
./detect_storage_candidates.sh
lsblk -f
```

Assuming the new disk is `/dev/sdb`:

```bash
sudo ./setup_storage_disk.sh /dev/sdb /srv/greendev-data
sudo ./setup_backup_directories.sh /srv/greendev-data
```

Run first backup:

```bash
sudo ./run_backup.sh /srv/greendev-data
sudo ./verify_backup_integrity.sh /srv/greendev-data/backups/snapshots/latest
sudo ./test_restore.sh /srv/greendev-data
```

Install backup service/timer:

```bash
sudo ./setup_backup_service.sh /srv/greendev-data
sudo systemctl start gsx-week5-backup.service
```

Verify:

```bash
sudo ./verify_week5_setup.sh /srv/greendev-data
```

## Step 7 — Optional NFS

Configure VirtualBox networking for both server and client VMs:

```text
Adapter 1: NAT
Adapter 2: Host-only Adapter
```

On server:

```bash
cd scripts/week5
sudo ./setup_nfs_server_optional.sh /srv/greendev-data/shared 192.168.56.0/24
```

On client:

```bash
sudo apt update
sudo apt install -y nfs-common
sudo mkdir -p /mnt/greendev-shared
sudo mount -t nfs -o vers=4 <SERVER_IP>:/srv/greendev-data/shared /mnt/greendev-shared
```

## Step 8 — Final verification

Run:

```bash
sudo ./scripts/week2/verify_week2_setup.sh
sudo ./scripts/week3/verify_week3_setup.sh
sudo ./scripts/week4/verify_week4_setup.sh
sudo ./scripts/week5/verify_week5_setup.sh /srv/greendev-data
```

Also check:

```bash
systemctl --failed
systemctl list-timers --all
df -h
lsblk -f
journalctl -p warning --since "today" --no-pager
```

## Notes

Do not run destructive storage scripts against the system disk. Always verify with `lsblk -f` before formatting.
