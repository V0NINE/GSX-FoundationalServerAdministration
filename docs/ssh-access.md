# SSH Access Guide

## Purpose

SSH is used for secure remote administration of the Debian VM. This avoids relying on the VirtualBox console for normal administration work.

## VirtualBox network configuration

The current setup uses NAT with port forwarding.

Recommended rule:

| Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
|---|---|---:|---:|---|---:|
| SSH | TCP | 127.0.0.1 | 2222 | empty/default | 22 |

With this rule, the host connects to port `2222`, and VirtualBox forwards the connection to port `22` inside the VM.

## First connection with password

Before SSH keys are installed, use bootstrap mode:

```bash
sudo ./configure_ssh_access.sh --mode bootstrap
```

Then connect from the host:

```bash
ssh -p 2222 gsx@127.0.0.1
```

## Key-based authentication

On the host machine, generate a key.

Preferred modern option:

```bash
ssh-keygen -t ed25519 -C "gsx-practice"
```

If the SSH client does not support Ed25519, use RSA:

```bash
ssh-keygen -t rsa -b 4096 -C "gsx-practice"
```

Copy the public key:

```bash
ssh-copy-id -p 2222 gsx@127.0.0.1
```

If `ssh-copy-id` is not available, manually append the public key to:

```text
/home/gsx/.ssh/authorized_keys
```

Required permissions on the VM:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Secure mode

Only enable secure mode after confirming that key-based login works.

```bash
sudo ./configure_ssh_access.sh --mode secure
```

Secure mode applies:

```text
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

## Test secure SSH login

From the host:

```bash
ssh -p 2222 gsx@127.0.0.1
```

Expected result: login succeeds without asking for the account password. It may ask for the SSH key passphrase if the key has one.

## Troubleshooting

### Permission denied

Check:

```bash
ls -ld ~/.ssh
ls -l ~/.ssh/authorized_keys
```

Expected:

```text
~/.ssh              700
authorized_keys     600
```

### Connection refused

Check that the service is running:

```bash
systemctl status ssh
```

Check the VirtualBox port forwarding rule.

### No matching key exchange method

Use a modern SSH client. On Windows, Git Bash or the built-in OpenSSH client in PowerShell usually works better than old SSH clients.

### Locked out after secure mode

Use the VirtualBox console to log in locally and return to bootstrap mode:

```bash
sudo ./configure_ssh_access.sh --mode bootstrap
```
