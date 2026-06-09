# Final Reflection

## Summary

This assignment built a foundational Debian server for GreenDevCorp. The work evolved from basic installation to secure access, services, observability, process control, access control, storage and disaster recovery.

The final result is not just a configured VM. It is a documented and repeatable infrastructure project.

## What went well

- SSH access was hardened with key-based authentication.
- Git was used to track scripts and documentation.
- Services were managed through systemd.
- Logs and timers made automation observable.
- Process and resource-control demos provided clear operational examples.
- Users and permissions followed least privilege.
- Backups were verified and restored.
- Optional NFS demonstrated networked storage.

## Main difficulties

### SSH and Git authentication

GitHub authentication required SSH keys rather than password authentication. This reinforced the importance of understanding authentication mechanisms.

### APT and networking

Some package installation issues were caused by stale package indexes or missing VM Internet access. This highlighted the need to distinguish DNS, routing and repository issues.

### systemd service paths

Some scripts worked manually but failed under systemd because dependencies were missing under `/opt/gsx-admin/scripts`. This demonstrated why services must be tested in the same environment where they run.

### Permissions and ACLs

Combining normal Unix permissions and ACLs can be subtle. The `done.log` policy was simpler and clearer with normal owner/group permissions.

### NFS networking

NFS required correct VirtualBox networking: NAT for Internet and host-only networking for VM-to-VM communication.

## Key lessons

- Automation must be idempotent and tested.
- Documentation is part of the infrastructure.
- A backup is not valid until it has been restored.
- Logs are essential for diagnosing failures.
- Least privilege prevents accidental damage.
- systemd provides a consistent model for services and timers.
- Resource limits should be verified, not assumed.
- Simple designs are often better when they meet the requirements.

## What would be improved in a production version

- Use Ansible instead of Bash for full configuration management.
- Add monitoring and alerting.
- Add offsite backups.
- Encrypt backup storage.
- Use centralized identity management.
- Add audit logging.
- Add automated tests for scripts.
- Add disk usage alerts.
- Harden NFS or replace it with a more controlled file-sharing design.
- Use LVM or another volume manager.

## Final assessment

The system meets the assignment goals for foundational server administration:

- it is usable;
- it is observable;
- it is automated;
- it is documented;
- it includes recovery procedures;
- it is defensible through documented design rationale.

