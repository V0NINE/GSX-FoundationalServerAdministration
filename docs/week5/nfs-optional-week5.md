# Week 5 Optional NFS Network Storage

## Purpose

The optional Week 5 task demonstrates networked storage. The server exports a shared directory with NFS, and a second VM mounts it as a client.

This proves that shared storage can be accessed across the network.

## Server-side export

The exported directory is:

```text
/srv/greendev-data/shared
```

Run on the server VM:

```bash
cd scripts/week5
sudo ./setup_nfs_server_optional.sh /srv/greendev-data/shared 192.168.56.0/24
```

This configures:

- `nfs-kernel-server`;
- `/etc/exports`;
- NFS service;
- export permissions for the host-only network.

## VirtualBox networking

Both VMs should have:

```text
Adapter 1: NAT
Adapter 2: Host-only Adapter
```

Purpose:

| Adapter | Purpose |
|---|---|
| NAT | Internet access and package installation |
| Host-only | VM-to-VM NFS traffic |

## Server checks

On the server:

```bash
ip addr
systemctl status nfs-server --no-pager
sudo exportfs -v
ls -ld /srv/greendev-data/shared
```

Expected:

- server has a `192.168.56.x` address;
- `nfs-server` is active;
- `/srv/greendev-data/shared` appears in `exportfs -v`.

## Client setup

On the client VM:

```bash
sudo apt update
sudo apt install -y nfs-common
sudo mkdir -p /mnt/greendev-shared
```

Mount manually:

```bash
sudo mount -t nfs -o vers=4 <SERVER_IP>:/srv/greendev-data/shared /mnt/greendev-shared
```

## Client checks

```bash
mount | grep greendev
df -h /mnt/greendev-shared
ls -ld /mnt/greendev-shared
ls -l /mnt/greendev-shared
```

## Persistent client mount

On the client, add to `/etc/fstab`:

```text
<SERVER_IP>:/srv/greendev-data/shared /mnt/greendev-shared nfs defaults,nofail,_netdev 0 0
```

Test:

```bash
sudo umount /mnt/greendev-shared
sudo mount -a
mount | grep greendev
```

## Write test

Depending on permissions, write access may require matching users/groups on both VMs.

Simple connectivity test:

```bash
ls -l /mnt/greendev-shared
```

Write test:

```bash
sudo touch /mnt/greendev-shared/client-test.txt
ls -l /mnt/greendev-shared
```

If normal users get permission denied, document it as a Unix permission issue rather than an NFS connectivity failure.

## Troubleshooting

### Client has no Internet

Check VirtualBox:

```text
Adapter 1: NAT
Adapter 2: Host-only
```

Inside client:

```bash
ip route
ping -c 3 8.8.8.8
ping -c 3 deb.debian.org
```

### mount says NFS remote address problem

Install NFS client tools:

```bash
sudo apt install -y nfs-common
```

Check:

```bash
command -v mount.nfs
```

### Cannot reach server

From client:

```bash
ping -c 3 <SERVER_IP>
```

If it fails, check host-only adapter on both VMs.

### Export not visible

On server:

```bash
sudo exportfs -ra
sudo exportfs -v
systemctl status nfs-server --no-pager
```

### Permission denied

Check server directory permissions:

```bash
ls -ld /srv/greendev-data/shared
getfacl /srv/greendev-data/shared
```

NFS does not bypass Unix permissions.

