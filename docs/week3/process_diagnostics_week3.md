# Week 3 Process Diagnostics

## Purpose

This document explains how to inspect processes and identify why a server may feel slow.

A slow server can be caused by:

- high CPU usage;
- high memory usage;
- too many processes;
- excessive I/O;
- a runaway background job;
- a service restarting repeatedly;
- a process stuck or waiting.

Week 3 focuses mainly on CPU, memory, process relationships and resource limits.

## Tools used

| Tool | Purpose |
|---|---|
| `ps` | Snapshot of running processes |
| `top` / `htop` | Interactive process monitoring |
| `pstree` | Parent-child process tree |
| `/proc` | Kernel process information |
| `systemctl` | Service state and main PID |
| `journalctl` | Logs for services |
| `cgroups` | Resource control and accounting |

## Top CPU consumers

Run:

```bash
./list_top_processes.sh cpu 10
```

This uses:

```bash
ps -eo pid,ppid,user,stat,pri,ni,%cpu,%mem,rss,vsz,etime,comm,args --sort=-%cpu
```

Important columns:

| Column | Meaning |
|---|---|
| `PID` | Process ID |
| `PPID` | Parent process ID |
| `USER` | User running the process |
| `STAT` | Process state |
| `PRI` | Kernel priority |
| `NI` | Nice value |
| `%CPU` | CPU usage |
| `%MEM` | Memory percentage |
| `RSS` | Resident memory in KB |
| `VSZ` | Virtual memory size in KB |
| `ELAPSED` | Time since process started |
| `COMMAND/ARGS` | Executable and arguments |

## Top memory consumers

Run:

```bash
./list_top_processes.sh mem 10
```

High memory usage is not always a problem. Linux uses memory aggressively for caching. The important question is whether real memory pressure exists.

Useful checks:

```bash
free -h
vmstat 1 5
```

Warning signs:

- swap usage increasing;
- system becoming unresponsive;
- OOM killer messages in logs;
- processes failing allocations.

## Process tree

Run:

```bash
./show_process_tree.sh
```

For a specific PID:

```bash
./show_process_tree.sh <PID>
```

The process tree helps answer:

- who launched this process?
- what child processes belong to it?
- is this process part of a service?
- did a parent process fail to clean up children?

## Specific process metrics

Run:

```bash
./process_metrics.sh <PID>
```

Example:

```bash
./process_metrics.sh 1
```

This displays:

- basic `ps` information;
- selected fields from `/proc/<PID>/status`;
- open file descriptor count;
- cgroup membership;
- process limits from `/proc/<PID>/limits`.

## Interpreting process state

Common `STAT` values:

| State | Meaning |
|---|---|
| `R` | Running or runnable |
| `S` | Sleeping |
| `D` | Uninterruptible sleep, often I/O wait |
| `T` | Stopped |
| `Z` | Zombie |
| `s` | Session leader |
| `l` | Multi-threaded |
| `+` | Foreground process group |

A zombie process (`Z`) has exited but its parent has not collected its status. A few short-lived zombies may be harmless; persistent zombies indicate a parent process issue.

## Troubleshooting checklist: server feels slow

1. Check load and memory:

```bash
uptime
free -h
```

2. Check top CPU processes:

```bash
./list_top_processes.sh cpu 10
```

3. Check top memory processes:

```bash
./list_top_processes.sh mem 10
```

4. Check process tree:

```bash
./show_process_tree.sh
```

5. If the process belongs to a systemd service:

```bash
systemctl status <service> --no-pager
journalctl -u <service> --since "1 hour ago" --no-pager
```

6. Inspect a suspicious PID:

```bash
./process_metrics.sh <PID>
```

7. Decide whether to wait, lower priority, pause, gracefully terminate or force kill.

## When is high CPU a problem?

A process using 90% CPU is not automatically a problem. It depends on context.

It may be acceptable if:

- it is an expected batch job;
- the server remains responsive;
- the process is limited;
- the workload is temporary.

It is a problem if:

- it affects other users;
- it was not expected;
- it runs indefinitely;
- it prevents services from responding;
- it has no resource limits;
- logs show failures or restart loops.
