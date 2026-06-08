# Week 3 Reflection

## What we learned

Week 3 showed that system administration requires more than starting and stopping services. A sysadmin must understand what processes are running, how they relate to each other and how they consume system resources.

The most important lessons were:

- `ps`, `pstree`, `top`, `htop` and `/proc` provide different views of the same process reality.
- A high CPU process is not automatically bad; context matters.
- `SIGTERM` and `SIGINT` allow graceful handling, while `SIGKILL` does not.
- A good service should clean up child processes and temporary files before exiting.
- systemd resource controls are enforced through cgroups.
- Resource limits must be verified, not just configured.

## Most challenging part

The most challenging part was demonstrating resource limits in a way that is visible and easy to explain. A simple workload using `yes` processes makes CPU usage obvious, while systemd properties and cgroup files show that limits are actually applied.

## What we would improve

In a more advanced system, we would add:

- persistent metrics collection;
- alerting when CPU or memory usage stays high;
- dashboards;
- per-user limits;
- better workload simulation with CPU, memory and I/O profiles.

## Interview preparation

### Why did we create a custom workload?

Because it gives a controlled and repeatable way to demonstrate CPU usage, process trees, signals and cgroups.

### Why not just use random real processes?

Using real system processes is riskier and less repeatable. A custom workload is safer for a lab demonstration.

### Why use systemd resource controls?

Because they are declarative, repeatable, tied to service lifecycle and enforced by the kernel through cgroups.

### When should SIGKILL be used?

Only when a process must be stopped and does not respond to graceful signals such as `SIGTERM`.

### How can we prove that limits work?

By showing:

```bash
systemctl show gsx-workload.service -p CPUQuotaPerSecUSec -p MemoryMax -p TasksMax
./check_cgroup_limits.sh gsx-workload.service
./monitor_unit_resources.sh gsx-workload.service 1 5
```
