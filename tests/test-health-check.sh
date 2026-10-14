#!/usr/bin/env bash

set -u

SCRIPT="./health-check.sh"
failures=0

check_contains() {
    local description="$1"
    local pattern="$2"

    if grep -Fq -- "$pattern" "$SCRIPT"; then
        echo "PASS: $description"
    else
        echo "FAIL: $description"
        failures=$((failures + 1))
    fi
}

check_contains "Script has a Bash shebang" "#!/usr/bin/env bash"
check_contains "Uptime check exists" "uptime"
check_contains "Memory check exists" "Memory Usage"
check_contains "Disk usage check exists" "Disk Usage"
check_contains "Disk warning threshold exists" "disk_usage >= 80"
check_contains "Service check exists" "Service Status"
check_contains "Logging uses tee" "tee -a"

echo
if (( failures == 0 )); then
    echo "All smoke tests passed."
    exit 0
else
    echo "$failures smoke test(s) failed."
    exit 1
fi
