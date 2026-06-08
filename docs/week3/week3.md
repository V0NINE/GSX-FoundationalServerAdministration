# Week 3 — Process Management and Resource Control

## Goal

The goal of Week 3 is to understand what is running on the server, diagnose resource usage problems, control processes safely and prevent one service or user workload from monopolizing the system.

The scenario is that the server feels slow and nobody knows why. The administrator must be able to answer:

- Which processes are using CPU or memory?
- What is the relationship between processes?
- How can a process be stopped safely?
- What is the difference between graceful termination and force killing?
- How can systemd/cgroups enforce CPU, memory and task limits?
- How do we prove that limits are actually applied?

## Implemented components

Week 3 adds:

- process diagnostic scripts;
- a signal-aware workload script;
- helper scripts to send signals;
- a systemd workload service with resource limits;
- cgroup inspection scripts;
- monitoring scripts;
- a verification script;
- documentation and evidence templates.

## Relevant files

```text
scripts/week3/
├── setup_week3_tools.sh
├── list_top_processes.sh
├── show_process_tree.sh
├── process_metrics.sh
├── signal_aware_workload.sh
├── start_workload_demo.sh
├── control_workload.sh
├── setup_workload_service.sh
├── check_cgroup_limits.sh
├── monitor_unit_resources.sh
├── test_resource_limits.sh
├── verify_week3_setup.sh
└── install_week3.sh

systemd/week3/
└── gsx-workload.service

docs/
├── week3.md
├── process-diagnostics-week3.md
├── signal-handling-week3.md
├── resource-control-week3.md
├── troubleshooting-week3.md
└── testing-evidence-week3.md
```

## Setup procedure

Create a Week 3 branch:

```bash
git checkout master
git pull origin master
git checkout -b week3-process-resource-control
```

Install the Week 3 baseline:

```bash
chmod +x scripts/week3/*.sh
cd scripts/week3
sudo ./install_week3.sh
```

The installer performs:

1. installation of process and monitoring tools;
2. installation of the resource-limited workload service;
3. baseline verification.

## Main verification command

```bash
sudo ./verify_week3_setup.sh
```

Expected result:

```text
[+] Week 3 verification passed.
```

## Process diagnostics

List top CPU consumers:

```bash
./list_top_processes.sh cpu 10
```

List top memory consumers:

```bash
./list_top_processes.sh mem 10
```

Show process tree:

```bash
./show_process_tree.sh
```

Show metrics for a specific process:

```bash
./process_metrics.sh <PID>
```

## Signal handling demonstration

Start a workload:

```bash
./start_workload_demo.sh 2
```

Ask it for status using `SIGUSR1`:

```bash
./control_workload.sh status
```

Pause/resume using `SIGUSR2`:

```bash
./control_workload.sh pause
./control_workload.sh pause
```

Gracefully stop using `SIGTERM`:

```bash
./control_workload.sh stop
```

Force kill using `SIGKILL`:

```bash
./start_workload_demo.sh 2
./control_workload.sh kill
```

## Resource-limited service

Start the systemd workload service:

```bash
sudo systemctl start gsx-workload.service
```

Inspect resource limits:

```bash
./check_cgroup_limits.sh gsx-workload.service
```

Monitor live usage:

```bash
./monitor_unit_resources.sh gsx-workload.service 1 5
```

Run full demonstration:

```bash
sudo ./test_resource_limits.sh
```

## Evidence to collect

Paste outputs in:

```text
docs/testing-evidence-week3.md
```

Minimum evidence:

```bash
./list_top_processes.sh cpu 10
./list_top_processes.sh mem 10
./show_process_tree.sh
./process_metrics.sh 1
./start_workload_demo.sh 2
./control_workload.sh status
./control_workload.sh pause
./control_workload.sh stop
sudo ./test_resource_limits.sh
sudo ./verify_week3_setup.sh
```

## Design summary

The workload script is intentionally simple and CPU-intensive. It launches `yes` worker processes so resource usage is visible and easy to test.

The systemd service uses resource controls:

```ini
CPUQuota=50%
MemoryMax=150M
TasksMax=50
```

These controls are enforced by cgroups. The scripts inspect both the systemd unit properties and the relevant cgroup files under `/sys/fs/cgroup`.

