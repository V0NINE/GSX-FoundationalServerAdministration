#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

# verify_access_control.sh - Verify Week 4 users, groups and permissions
#
# USAGE:
#   sudo ./verify_access_control.sh

require_root

FAILED=0
TEAM_GROUP="greendevcorp"
TEAM_HOME="/home/greendevcorp"
BIN_DIR="$TEAM_HOME/bin"
SHARED_DIR="$TEAM_HOME/shared"
DONE_LOG="$TEAM_HOME/done.log"

pass() { output_message SUCCESS "$1"; }
fail() { output_message ERROR "$1"; FAILED=1; }

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        pass "$description"
    else
        fail "$description"
    fi
}

check "Group $TEAM_GROUP exists" getent group "$TEAM_GROUP"

for dev in dev1 dev2 dev3 dev4; do
    check "User $dev exists" id "$dev"
    if id "$dev" >/dev/null 2>&1; then
        if id -nG "$dev" | grep -qw "$TEAM_GROUP"; then
            pass "User $dev belongs to $TEAM_GROUP"
        else
            fail "User $dev does not belong to $TEAM_GROUP"
        fi

        HOME_DIR="$(getent passwd "$dev" | cut -d: -f6)"
        PERM="$(stat -c '%a' "$HOME_DIR")"
        if [ "$PERM" = "700" ]; then
            pass "Home directory for $dev is private ($PERM)"
        else
            fail "Home directory for $dev should be 700, current=$PERM"
        fi
    fi
done

check "$TEAM_HOME exists" test -d "$TEAM_HOME"
check "$BIN_DIR exists" test -d "$BIN_DIR"
check "$SHARED_DIR exists" test -d "$SHARED_DIR"
check "$DONE_LOG exists" test -f "$DONE_LOG"

[ "$(stat -c '%a' "$TEAM_HOME")" = "2750" ] && pass "$TEAM_HOME permissions are 2750" || fail "$TEAM_HOME permissions should be 2750"
[ "$(stat -c '%a' "$BIN_DIR")" = "2750" ] && pass "$BIN_DIR permissions are 2750" || fail "$BIN_DIR permissions should be 2750"
[ "$(stat -c '%a' "$SHARED_DIR")" = "3770" ] && pass "$SHARED_DIR permissions are 3770" || fail "$SHARED_DIR permissions should be 3770"
[ "$(stat -c '%a' "$DONE_LOG")" = "640" ] && pass "$DONE_LOG permissions are 640" || fail "$DONE_LOG permissions should be 640"

# dev1 can write done.log
if runuser -u dev1 -- bash -c "echo "$(date --iso-8601=seconds) dev1: verification write" >> '$DONE_LOG'"; then
    pass "dev1 can append to done.log"
else
    fail "dev1 cannot append to done.log"
fi

# dev2 can read but cannot write done.log
if runuser -u dev2 -- bash -c "test -r '$DONE_LOG' && head -n 1 '$DONE_LOG' >/dev/null"; then
    pass "dev2 can read done.log"
else
    fail "dev2 cannot read done.log"
fi

if runuser -u dev2 -- bash -c "echo illegal-write >> '$DONE_LOG'" 2>/dev/null; then
    fail "dev2 should not be able to append to done.log"
else
    pass "dev2 cannot append to done.log"
fi

# Shared directory: dev2 creates a file, dev3 must not delete it because sticky bit is set.
TEST_FILE="$SHARED_DIR/week4-dev2-sticky-test.txt"
rm -f "$TEST_FILE"

if runuser -u dev2 -- bash -c "echo created-by-dev2 > '$TEST_FILE'"; then
    pass "dev2 can create files in shared directory"
else
    fail "dev2 cannot create files in shared directory"
fi

if [ -f "$TEST_FILE" ]; then
    FILE_GROUP="$(stat -c '%G' "$TEST_FILE")"
    if [ "$FILE_GROUP" = "$TEAM_GROUP" ]; then
        pass "Files in shared directory inherit group $TEAM_GROUP"
    else
        fail "Shared file should inherit group $TEAM_GROUP, current=$FILE_GROUP"
    fi

    if runuser -u dev3 -- bash -c "rm '$TEST_FILE'" 2>/dev/null; then
        fail "dev3 should not be able to delete dev2 file because sticky bit is enabled"
    else
        pass "Sticky bit prevents dev3 from deleting dev2 file"
    fi
fi

rm -f "$TEST_FILE"

# Team bin access and done-add helper.
if su - dev1 -s /bin/bash -c "command -v done-add >/dev/null"; then
    pass "dev1 receives /home/greendevcorp/bin in PATH"
else
    fail "dev1 does not receive /home/greendevcorp/bin in PATH"
fi

if runuser -u dev1 -- bash -lc "done-add verification-task-from-dev1"; then
    pass "dev1 can use done-add helper"
else
    fail "dev1 cannot use done-add helper"
fi

if runuser -u dev2 -- bash -lc "done-add should-fail" 2>/dev/null; then
    fail "dev2 should not be able to use done-add successfully"
else
    pass "done-add rejects dev2 as expected"
fi

if [ "$FAILED" -eq 0 ]; then
    output_message SUCCESS "Access-control verification passed."
else
    output_message ERROR "Access-control verification failed."
fi

exit "$FAILED"
