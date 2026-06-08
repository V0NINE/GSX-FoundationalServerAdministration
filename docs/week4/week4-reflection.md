# Week 4 Reflection

## What we learned

Week 4 focused on secure collaboration. The main lesson is that access control is not only about making files accessible; it is about making them accessible only to the right users.

Important concepts:

- users and groups model organizational roles;
- private home directories protect personal work;
- group permissions allow collaboration;
- setgid helps preserve group ownership in shared directories;
- sticky bit prevents users from deleting each other's files;
- ACLs allow more precise permission models;
- PAM limits protect the system from accidental abuse.

## Most challenging part

The most challenging part was making the permission model both secure and testable.

For example, `done.log` had a simple policy: all team members can read it, but only `dev1` can write. This can be implemented with normal Unix ownership:

```text
owner: dev1
group: greendevcorp
mode: 0640
```

Using unnecessary ACLs can make verification harder because ACL masks affect effective permissions. The simpler solution is better when it satisfies the policy.

## Design decisions

### Why group `greendevcorp`?

Because developers share team resources. A group makes it easier to grant access consistently and onboard future developers.

### Why private home directories?

Because developers should not read or modify each other's private files unless explicitly shared.

### Why setgid on shared directories?

Because new files in the shared directory should inherit group `greendevcorp`, avoiding broken collaboration caused by inconsistent group ownership.

### Why sticky bit?

Because the shared directory is writable by the group, but users should not be able to delete files created by other users.

### Why PAM limits?

Because user sessions can accidentally consume too many resources. Limits reduce the risk of one user affecting the whole server.

## What we would improve

For a larger organization, we would consider:

- centralized identity management;
- SSH key onboarding automation;
- separate groups for developers, operations and contractors;
- more granular ACL policies;
- audit logging for sensitive files;
- automated offboarding procedures.

## Interview preparation

### A user cannot access a shared file. What do we check?

1. `id <user>`
2. `ls -l <file>`
3. `ls -ld <parent-directory>`
4. `getfacl <file>`
5. `getfacl <parent-directory>`
6. check whether the user needs to log out/in for group changes.

### A user can write to a file they should only read. What do we check?

1. file owner and group;
2. mode bits;
3. ACL entries;
4. ACL mask;
5. parent directory permissions;
6. whether scripts changed permissions unexpectedly.

### What is least privilege?

Least privilege means users receive only the access they need to do their job, and no more.
