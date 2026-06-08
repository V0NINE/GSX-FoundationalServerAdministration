#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

# setup_pam_limits.sh - Configure per-user resource limits through PAM
#
# USAGE:
#   sudo ./setup_pam_limits.sh
#
# Notes:
#   - nofile: max open files
#   - nproc: max processes/tasks
#   - as: virtual memory address space in KB
#   - cpu: maximum CPU time, interpreted by pam_limits/ulimit

require_root

LIMITS_FILE="/etc/security/limits.d/90-greendevcorp.conf"
TEAM_GROUP="greendevcorp"

cat > "$LIMITS_FILE" <<EOF
# Managed by GSX Week 4 scripts.
# Resource limits for GreenDevCorp developers.

@${TEAM_GROUP} soft nofile 1024
@${TEAM_GROUP} hard nofile 2048

@${TEAM_GROUP} soft nproc 100
@${TEAM_GROUP} hard nproc 150

@${TEAM_GROUP} soft as 524288
@${TEAM_GROUP} hard as 786432

@${TEAM_GROUP} soft cpu 10
@${TEAM_GROUP} hard cpu 15
EOF

chmod 0644 "$LIMITS_FILE"

for pam_file in /etc/pam.d/common-session /etc/pam.d/common-session-noninteractive; do
    if [ -f "$pam_file" ]; then
        if grep -Eq '^session\s+required\s+pam_limits\.so' "$pam_file"; then
            output_message WARNING "pam_limits.so already enabled in $pam_file."
        else
            echo "session required pam_limits.so" >> "$pam_file"
            output_message SUCCESS "Enabled pam_limits.so in $pam_file."
        fi
    fi
done

output_message SUCCESS "PAM limits configured in $LIMITS_FILE."
cat "$LIMITS_FILE"
