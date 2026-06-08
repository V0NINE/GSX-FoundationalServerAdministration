#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

# setup_team_directories.sh - Create GreenDevCorp shared directory structure
#
# USAGE:
#   sudo ./setup_team_directories.sh

require_root

TEAM_GROUP="greendevcorp"
TEAM_HOME="/home/greendevcorp"
BIN_DIR="$TEAM_HOME/bin"
SHARED_DIR="$TEAM_HOME/shared"
DONE_LOG="$TEAM_HOME/done.log"

if ! getent group "$TEAM_GROUP" >/dev/null; then
    groupadd "$TEAM_GROUP"
fi

mkdir -p "$BIN_DIR" "$SHARED_DIR"

chown root:"$TEAM_GROUP" "$TEAM_HOME" "$BIN_DIR" "$SHARED_DIR"
chmod 2750 "$TEAM_HOME"
chmod 2750 "$BIN_DIR"
chmod 3770 "$SHARED_DIR"

# Default ACLs for shared work. New files inherit greendevcorp group access.
setfacl -m "g:${TEAM_GROUP}:rwx,m::rwx,o::---" "$SHARED_DIR"
setfacl -d -m "g:${TEAM_GROUP}:rwx,m::rwx,o::---" "$SHARED_DIR"

# Team task log: readable by the team, writable only by dev1.
touch "$DONE_LOG"
if id dev1 >/dev/null 2>&1; then
    chown dev1:"$TEAM_GROUP" "$DONE_LOG"
else
    chown root:"$TEAM_GROUP" "$DONE_LOG"
fi

setfacl -b "$DONE_LOG" 2>/dev/null || true
chmod 0640 "$DONE_LOG"


# Helper script: only dev1 may add completed tasks.
cat > "$BIN_DIR/done-add" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

DONE_LOG="/home/greendevcorp/done.log"

if [ "$(id -un)" != "dev1" ]; then
    echo "Only dev1 is authorized to add entries to $DONE_LOG." >&2
    exit 1
fi

if [ "$#" -eq 0 ]; then
    echo "USAGE: done-add <completed task description>" >&2
    exit 1
fi

printf '%s %s: %s\n' "$(date --iso-8601=seconds)" "$(id -un)" "$*" >> "$DONE_LOG"
EOF

chown root:"$TEAM_GROUP" "$BIN_DIR/done-add"
chmod 0750 "$BIN_DIR/done-add"

output_message SUCCESS "Team directories configured:"
ls -ld "$TEAM_HOME" "$BIN_DIR" "$SHARED_DIR"
ls -l "$DONE_LOG" "$BIN_DIR/done-add"
getfacl -p "$SHARED_DIR" "$DONE_LOG" >/tmp/gsx-week4-acl-report.txt
output_message INFO "ACL report saved at /tmp/gsx-week4-acl-report.txt"
