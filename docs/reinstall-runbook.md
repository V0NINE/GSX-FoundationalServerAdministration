# Reinstall / Recovery Runbook — Week 1

## Scenario

The VM has been reset or reinstalled and the Week 1 baseline must be restored.

## Procedure

### 1. Start from Debian VM

Log in locally as `gsx`.

### 2. Install Git and sudo if missing

If `sudo` is not installed:

```bash
su -
apt update
apt install -y sudo git
usermod -aG sudo gsx
exit
```

Log out and log back in.

### 3. Clone repository

```bash
git clone <REPOSITORY_URL>
cd <REPOSITORY_NAME>/scripts
chmod +x *.sh
```

### 4. Apply baseline setup

```bash
sudo ./install_week1.sh --ssh-mode bootstrap --sudo-user gsx
```

### 5. Configure VirtualBox port forwarding

Use NAT port forwarding:

| Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
|---|---|---:|---:|---|---:|
| SSH | TCP | 127.0.0.1 | 2222 | empty/default | 22 |

### 6. Test SSH

From host:

```bash
ssh -p 2222 gsx@127.0.0.1
```

### 7. Install SSH key

From host:

```bash
ssh-copy-id -p 2222 gsx@127.0.0.1
```

### 8. Enable secure mode

Only after key login works:

```bash
sudo ./configure_ssh_access.sh --mode secure
```

### 9. Verify

```bash
sudo ./verify_week1_setup.sh
```

## Expected recovery time

For Week 1, expected recovery time is approximately 15–30 minutes, depending on network speed and package installation time.
