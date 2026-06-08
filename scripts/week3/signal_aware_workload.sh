#!/usr/bin/env bash
# signal_aware_workload.sh - Workload that handles SIGINT, SIGTERM, SIGUSR1 and SIGUSR2
#
# USAGE:
#   ./signal_aware_workload.sh [number_of_workers]

set -euo pipefail

WORKERS="${1:-2}"
RUN_DIR="/tmp/gsx-week3-workload"
PID_FILE="$RUN_DIR/workload.pid"
CHILDREN_FILE="$RUN_DIR/children.pids"
LOG_FILE="$RUN_DIR/workload.log"

mkdir -p "$RUN_DIR"
: > "$CHILDREN_FILE"

PAUSED=0

log() {
    echo "$(date --iso-8601=seconds) [workload $$] $*" | tee -a "$LOG_FILE"
}

cleanup() {
    log "Graceful shutdown requested. Stopping children..."
    if [ -f "$CHILDREN_FILE" ]; then
        while read -r child; do
            if [ -n "$child" ] && kill -0 "$child" 2>/dev/null; then
                kill -TERM "$child" 2>/dev/null || true
            fi
        done < "$CHILDREN_FILE"
    fi
    sleep 1
    if [ -f "$CHILDREN_FILE" ]; then
        while read -r child; do
            if [ -n "$child" ] && kill -0 "$child" 2>/dev/null; then
                kill -KILL "$child" 2>/dev/null || true
            fi
        done < "$CHILDREN_FILE"
    fi
    rm -f "$PID_FILE" "$CHILDREN_FILE"
    log "Shutdown complete."
}

print_status() {
    log "Status requested with SIGUSR1."
    if [ -f "$CHILDREN_FILE" ]; then
        while read -r child; do
            if [ -n "$child" ]; then
                if kill -0 "$child" 2>/dev/null; then
                    log "Child $child is alive."
                else
                    log "Child $child is not running."
                fi
            fi
        done < "$CHILDREN_FILE"
    fi
}

toggle_pause() {
    if [ "$PAUSED" -eq 0 ]; then
        PAUSED=1
        log "Pause requested with SIGUSR2."
        while read -r child; do
            [ -n "$child" ] && kill -STOP "$child" 2>/dev/null || true
        done < "$CHILDREN_FILE"
    else
        PAUSED=0
        log "Resume requested with SIGUSR2."
        while read -r child; do
            [ -n "$child" ] && kill -CONT "$child" 2>/dev/null || true
        done < "$CHILDREN_FILE"
    fi
}

trap 'cleanup; exit 0' INT TERM
trap 'print_status' USR1
trap 'toggle_pause' USR2

echo "$$" > "$PID_FILE"
log "Starting workload with $WORKERS yes workers."
log "Main PID: $$"
log "Send SIGUSR1 for status, SIGUSR2 to pause/resume, SIGTERM/SIGINT for graceful shutdown."

for i in $(seq 1 "$WORKERS"); do
    yes "gsx-week3-worker-$i" >/dev/null &
    child="$!"
    echo "$child" >> "$CHILDREN_FILE"
    log "Started worker $i with PID $child."
done

while true; do
    sleep 5
    alive=0
    while read -r child; do
        if [ -n "$child" ] && kill -0 "$child" 2>/dev/null; then
            alive=$((alive + 1))
        fi
    done < "$CHILDREN_FILE"
    log "Heartbeat: $alive workers alive, paused=$PAUSED."
done
