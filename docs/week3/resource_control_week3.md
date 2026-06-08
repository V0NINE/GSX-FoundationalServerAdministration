# Week 3 Resource Control

## Purpose

Resource control prevents a single service or workload from consuming all CPU, memory or process slots. This is important for keeping the server responsive under load.

Week 3 uses `systemd` resource controls backed by Linux cgroups.

## Demo service

The service is:

```text
gsx-workload.service
```

The unit file is stored in the repository at:

```text
systemd/week3/gsx-workload.service
```

It is installed to:

```text
/etc/systemd/system/gsx-workload.service
```

## Service definition

Important directives:

```ini
[Service]
Type=simple
ExecStart=/opt/gsx-admin/scripts/week3/signal_aware_workload.sh 4
Restart=on-failure
RestartSec=3s

CPUQuota=50%
MemoryMax=150M
TasksMax=50

NoNewPrivileges=true
PrivateTmp=true
```

## Meaning of the limits

| Directive | Meaning |
|---|---|
| `CPUQuota=50%` | The service can use up to roughly half of one CPU core |
| `MemoryMax=150M` | The service is limited to 150 MB of memory |
| `TasksMax=50` | The service can create at most 50 tasks/processes |
| `Restart=on-failure` | The service is restarted if it exits unexpectedly |

## Start and stop the service

Start:

```bash
sudo systemctl start gsx-workload.service
```

Stop:

```bash
sudo systemctl stop gsx-workload.service
```

Status:

```bash
systemctl status gsx-workload.service --no-pager
```

Logs:

```bash
journalctl -u gsx-workload.service --since "10 minutes ago" --no-pager
```

## Inspect systemd properties

```bash
systemctl show gsx-workload.service \
  -p ControlGroup \
  -p CPUQuotaPerSecUSec \
  -p MemoryMax \
  -p TasksMax \
  -p MainPID
```

Or use:

```bash
./check_cgroup_limits.sh gsx-workload.service
```

## Inspect cgroup files

The script prints the cgroup path, usually under:

```text
/sys/fs/cgroup/system.slice/gsx-workload.service
```

Important files:

| File | Meaning |
|---|---|
| `cpu.max` | CPU quota and period |
| `memory.max` | Maximum memory allowed |
| `memory.current` | Current memory usage |
| `pids.max` | Maximum number of tasks |
| `pids.current` | Current number of tasks |
| `cgroup.procs` | Processes in the cgroup |

## Monitor resource usage

```bash
./monitor_unit_resources.sh gsx-workload.service 1 5
```

This samples the main process and its child processes.

If the script reports `error: improper list`, the issue is only the formatting of child PIDs for `ps -p`. Fix by generating comma-separated PIDs:

```bash
children="$(pgrep -P "$MAIN_PID" | paste -sd, - || true)"
```

## Full resource limit test

```bash
sudo ./test_resource_limits.sh
```

Expected result:

- the service starts;
- systemd reports configured limits;
- cgroup files show the applied limits;
- resource monitoring displays the workload processes;
- the script finishes successfully.

## How to prove that limits are enforced

Evidence should include:

```bash
systemctl show gsx-workload.service -p CPUQuotaPerSecUSec -p MemoryMax -p TasksMax
./check_cgroup_limits.sh gsx-workload.service
./monitor_unit_resources.sh gsx-workload.service 1 5
```

For stronger proof, compare a workload running without systemd limits against the same workload under `gsx-workload.service`.

## Design rationale

The workload is intentionally simple because the goal is not to simulate a real application, but to demonstrate process inspection, signals and resource controls clearly.

`systemd` resource controls are preferred over manual process management because they are:

- repeatable;
- documented in the unit file;
- integrated with service lifecycle;
- observable through `systemctl`;
- enforced by cgroups.
