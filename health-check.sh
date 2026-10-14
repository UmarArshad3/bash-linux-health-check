#!/usr/bin/env bash

# Linux Server Health Check
# Reports basic system health information.

set -u
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/health-check.log"

mkdir -p "$LOG_DIR"

if ! touch "$LOG_FILE" 2>/dev/null; then
    echo "ERROR: Cannot write to log file: $LOG_FILE" >&2
    exit 1
fi

exec > >(tee -a "$LOG_FILE") 2>&1
echo "================================="
echo "       SERVER HEALTH CHECK"
echo "================================="

echo
echo "Check time: $(date)"
echo "Hostname: $(hostname)"

echo
echo "----- System Uptime -----"
uptime
echo
echo "----- Memory Usage -----"

if [[ "$(uname -s)" == "Linux" ]] && command -v free >/dev/null 2>&1; then
    free -h
elif [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Memory details on macOS:"
    vm_stat
else
    echo "Memory check is unavailable on this system."
fi
echo
echo "----- Disk Usage -----"
df -h /

disk_usage=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

if [[ "$disk_usage" =~ ^[0-9]+$ ]]; then
    if (( disk_usage >= 80 )); then
        echo "WARNING: Root filesystem usage is ${disk_usage}%."
    else
        echo "OK: Root filesystem usage is ${disk_usage}%."
    fi
else
    echo "ERROR: Could not determine root filesystem usage."
fi
echo
echo "----- Service Status -----"

if command -v systemctl >/dev/null 2>&1; then
    service_name="ssh"

    if systemctl is-active --quiet "$service_name"; then
        echo "OK: Service '$service_name' is active."
    else
        echo "WARNING: Service '$service_name' is not active."
    fi
else
    echo "SKIP: systemctl is not available on this operating system."
fi
