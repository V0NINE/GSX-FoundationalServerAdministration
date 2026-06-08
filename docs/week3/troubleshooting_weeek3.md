# Week 3 Troubleshooting Guide

## The server feels slow

Start with general checks:

```bash
uptime
free -h
```

Then inspect top consumers:

```bash
./list_top_processes.sh cpu 10
./list_top_processes.sh mem 10
```

Check the process tree:

```bash
./show_process_tree.sh
```

If a suspicious process is found:

```bash
./process_metrics.sh <PID>
```

If the process belongs to a systemd service:

```bash
systemctl status <service> --no-pager
journalctl -u <service> --since "1 hour ago" --no-pager
```

## A process is using 90% CPU

Do not immediately kill it. First determine:

- who owns the process;
- whether it is expected;
- how long it has been running;
- whether it belongs to a service;
- whether it has resource limits;
- whether it affects other users.

Useful commands:

```bash
ps -p <PID> -o pid,ppid,user,stat,pri,ni,%cpu,%mem,etime,comm,args
./show_process_tree.sh <PID>
./process_metrics.sh <PID>
```

Possible actions:

```bash
renice +10 -p <PID>
kill -TERM <PID>
kill -KILL <PID>
```

Use `SIGKILL` only as a last resort.

## Workload demo is already running

Check:

```bash
cat /tmp/gsx-week3-workload/workload.pid
ps -p "$(cat /tmp/gsx-week3-workload/workload.pid)"
```

Stop gracefully:

```bash
./control_workload.sh stop
```

If it does not stop:

```bash
./control_workload.sh kill
```

## Workload PID file exists but process is gone

Remove stale files:

```bash
rm -f /tmp/gsx-week3-workload/workload.pid
rm -f /tmp/gsx-week3-workload/children.pids
```

Start again:

```bash
./start_workload_demo.sh 2
```

## signal_aware_workload.sh does not respond to status

Check that the main PID exists:

```bash
cat /tmp/gsx-week3-workload/workload.pid
ps -p "$(cat /tmp/gsx-week3-workload/workload.pid)"
```

Send the signal manually:

```bash
kill -USR1 "$(cat /tmp/gsx-week3-workload/workload.pid)"
tail -n 20 /tmp/gsx-week3-workload/workload.log
```

## gsx-workload.service is not installed

Run:

```bash
sudo ./setup_workload_service.sh
```

Check:

```bash
systemctl status gsx-workload.service --no-pager
```

## gsx-workload.service does not start

Check logs:

```bash
journalctl -u gsx-workload.service -n 50 --no-pager
```

Common causes:

- script missing from `/opt/gsx-admin/scripts/week3`;
- script is not executable;
- unit file syntax error;
- systemd was not reloaded.

Fix:

```bash
sudo ./setup_workload_service.sh
sudo systemctl daemon-reload
sudo systemctl restart gsx-workload.service
```

## Resource limits do not appear

Check systemd properties:

```bash
systemctl show gsx-workload.service -p CPUQuotaPerSecUSec -p MemoryMax -p TasksMax
```

Check cgroup path:

```bash
systemctl show gsx-workload.service -p ControlGroup
```

Run:

```bash
./check_cgroup_limits.sh gsx-workload.service
```

If the unit file was modified:

```bash
sudo systemctl daemon-reload
sudo systemctl restart gsx-workload.service
```

## monitor_unit_resources.sh shows "improper list"

This is a formatting issue when passing child PIDs to `ps`.

Fix this line:

```bash
children="$(pgrep -P "$MAIN_PID" | tr '\n' ' ' || true)"
```

Replace it with:

```bash
children="$(pgrep -P "$MAIN_PID" | paste -sd, - || true)"
```

`ps -p` expects a comma-separated list, not a space-separated list inside one argument.

## verify_week3_setup.sh fails

Run:

```bash
sudo ./verify_week3_setup.sh
```

For missing packages:

```bash
sudo ./setup_week3_tools.sh
```

For missing service:

```bash
sudo ./setup_workload_service.sh
```

Then verify again:

```bash
sudo ./verify_week3_setup.sh
```

## Clean up after demos

Stop the systemd service:

```bash
sudo systemctl stop gsx-workload.service
```

Stop manual workload:

```bash
./control_workload.sh stop
```

If needed:

```bash
pkill -f signal_aware_workload.sh
pkill yes
rm -rf /tmp/gsx-week3-workload
```

Be careful with `pkill yes`: only use it in the lab VM if you know the demo workload is the only `yes` process running.
