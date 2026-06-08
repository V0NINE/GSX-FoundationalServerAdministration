# Week 3 Signal Handling

## Purpose

Linux signals are a way to notify or control processes. Week 3 demonstrates how processes can react to signals and how administrators can stop or control workloads safely.

## Demo workload

The demo script is:

```text
scripts/week3/signal_aware_workload.sh
```

It starts one or more CPU-consuming worker processes and handles several signals:

| Signal | Action |
|---|---|
| `SIGUSR1` | Print status |
| `SIGUSR2` | Toggle pause/resume |
| `SIGTERM` | Graceful shutdown |
| `SIGINT` | Graceful shutdown |
| `SIGKILL` | Force kill, cannot be handled |

## Start the demo

```bash
./start_workload_demo.sh 2
```

This starts a main workload process and two `yes` worker processes.

The PID is stored in:

```text
/tmp/gsx-week3-workload/workload.pid
```

Logs are written to:

```text
/tmp/gsx-week3-workload/workload.log
```

## Request status with SIGUSR1

```bash
./control_workload.sh status
```

This sends:

```bash
kill -USR1 <PID>
```

Expected behaviour: the workload logs a status message and lists whether child workers are alive.

## Pause and resume with SIGUSR2

Pause:

```bash
./control_workload.sh pause
```

Resume:

```bash
./control_workload.sh pause
```

The script uses `SIGSTOP` and `SIGCONT` internally for child processes.

This demonstrates that a process can implement custom signal behaviour.

## Graceful shutdown with SIGTERM

```bash
./control_workload.sh stop
```

This sends:

```bash
kill -TERM <PID>
```

Expected behaviour:

- the main process receives `SIGTERM`;
- it runs cleanup logic;
- it terminates child workers;
- it removes PID files;
- it logs shutdown completion.

## Force kill with SIGKILL

```bash
./start_workload_demo.sh 2
./control_workload.sh kill
```

This sends:

```bash
kill -KILL <PID>
```

`SIGKILL` cannot be trapped or ignored. The process stops immediately and does not run cleanup code.

## SIGTERM vs SIGKILL

| Signal | Can be handled? | Allows cleanup? | Typical use |
|---|---:|---:|---|
| `SIGTERM` | Yes | Yes | Normal stop request |
| `SIGINT` | Yes | Yes | Ctrl+C / interrupt |
| `SIGKILL` | No | No | Last resort |
| `SIGUSR1` | Yes | Application-defined | Custom status/debug |
| `SIGUSR2` | Yes | Application-defined | Custom action |

## Recommended process control approach

1. Try graceful stop first:

```bash
kill -TERM <PID>
```

2. Wait and check:

```bash
ps -p <PID>
```

3. If the process does not exit and must be stopped:

```bash
kill -KILL <PID>
```

4. For services, prefer systemd:

```bash
sudo systemctl stop <service>
sudo systemctl kill <service>
```

## Why graceful shutdown matters

A graceful shutdown lets the process:

- flush data to disk;
- close files and network sockets;
- remove temporary files;
- stop child processes;
- write final logs;
- avoid corrupting state.

Force killing a process is sometimes necessary, but it should be considered a last resort.

## Evidence to collect

```bash
./start_workload_demo.sh 2
./control_workload.sh status
./control_workload.sh pause
./control_workload.sh pause
./control_workload.sh stop
tail -n 50 /tmp/gsx-week3-workload/workload.log
```

For force kill:

```bash
./start_workload_demo.sh 2
./control_workload.sh kill
tail -n 50 /tmp/gsx-week3-workload/workload.log
```

In the reflection, explain why the graceful stop logs cleanup while `SIGKILL` does not.
