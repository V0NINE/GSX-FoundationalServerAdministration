# Week 1 Testing Evidence

Use this file to paste terminal output or add screenshots proving that the Week 1 setup works.

## 1. Debian VM login

Command/evidence:

```text
TODO: paste evidence here
```

## 2. Clean snapshot

Snapshot name:

```text
TODO: week0-clean or equivalent
```

## 3. SSH service active

Command:

```bash
systemctl is-active ssh
systemctl is-enabled ssh
```

Output:

```text
TODO: paste output here
```

## 4. SSH access from host

Command from host:

```bash
ssh -p 2222 gsx@127.0.0.1
```

Output:

```text
TODO: paste output here
```

## 5. Sudo works

Command:

```bash
sudo whoami
```

Expected:

```text
root
```

Actual:

```text
TODO: paste output here
```

## 6. Admin directories

Command:

```bash
ls -ld /opt/gsx-admin /opt/gsx-admin/scripts /opt/gsx-admin/configs /opt/gsx-admin/docs /var/backups/gsx
```

Output:

```text
TODO: paste output here
```

## 7. Backup

Command:

```bash
sudo ./backup_admin_data.sh
ls -lh /var/backups/gsx
```

Output:

```text
TODO: paste output here
```

## 8. Verification script

Command:

```bash
sudo ./verify_week1_setup.sh
```

Output:

```text
TODO: paste output here
```

## 9. Git status

Command:

```bash
git status
git log --oneline --max-count=5
```

Output:

```text
TODO: paste output here
```
