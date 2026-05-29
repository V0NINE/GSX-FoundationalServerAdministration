# Week 1 Reflection

## What we learned

This week we learned that basic server administration is not only about installing packages. A system must be accessible, secure, repeatable and documented.

The most important ideas were:

- SSH is the standard way to administer Linux servers remotely.
- Root login should be avoided; sudo gives better control and accountability.
- Git is useful not only for application code, but also for infrastructure scripts and documentation.
- Scripts should be idempotent so that re-running them is safe.
- Documentation is part of the infrastructure, not an optional extra.

## Main difficulty

The main difficulty was avoiding lockout while hardening SSH. Disabling password authentication is safer, but doing it before testing public-key authentication can make the server inaccessible remotely.

The solution was to use two SSH modes:

- `bootstrap` for initial setup;
- `secure` for the final state.

## What we would improve

For a larger environment, Bash scripts may become difficult to maintain. In the future, we would consider a configuration management tool such as Ansible.

We would also improve monitoring and alerting once services are introduced in Week 2.

## Questions to prepare for oral defense

### Why SSH?

Because it is encrypted, standard, automatable and designed for remote Linux administration.

### Why disable root login?

Because root is too powerful to expose directly. A normal user with sudo provides better accountability and follows least privilege.

### Why use Git?

Because infrastructure changes should be tracked, reviewed and reproducible.

### What happens if SSH secure mode breaks access?

Use the VirtualBox console and return to bootstrap mode:

```bash
sudo ./configure_ssh_access.sh --mode bootstrap
```

### What is still missing after Week 1?

The system does not yet include production services, monitoring, user/team access control, storage expansion or a complete disaster recovery strategy. Those are addressed in later weeks.
