#!/bin/bash
# configure_sudoers.sh - Add a list of users to sudoers
#
# PURPOSE: 
#   Add a list of users passed as arguments, after checking each one
#   exists and is not already a sudoer
#
# USAGE:
#   ./configure_sudoers.sh <username> ...
#
# EXIT CODES:
#   0 - All users have been added
#  -1 - No username provided (at least one required)
#   1 - Syntax error in at least one user's sudoer file


# Define colors for readable script output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

ERROR="$RED[x]$RESET"
WARNING="$YELLOW[!]$RESET"
SUCCESS="$GREEN[+]$RESET"

EXIT=0


set -euo pipefail

if [ $# -eq 0 ]; then
    echo -e "$ERROR At least one username is required." >&2
    exit -1
fi

cleanup() {
    local f="$1"
    echo -e "$WARNING Cleanup: removed $f."
    rm -f "$f"
}

# For each provided username
for user in "$@"; do echo
    
    FILE="/etc/sudoers.d/$user"

    # Ensure user exists and is not in sudo group or /etc/sudoers.d/
    # /----
    if ! id -un "$user"  &> /dev/null; then
	echo -e "$WARNING User $user does not exist."
	continue
    fi

    if id -nG "$user" | grep -wq sudo; then
	echo -e "$WARNING User $user is already in sudo group."
	continue
    fi

    if [ -f "$FILE" ]; then
	echo -e "$WARNING User $user is already in sudoers.d."
	continue
    fi
    # \----

    # Create temporary sudoers file and setup cleanup in case of error
    echo "$user ALL=(ALL) ALL" > "$FILE"

    trap "cleanup '$FILE'" ERR

    echo "Adding $user..."

    # Validate syntax, then add to /etc/sudoers.d
    if visudo -c -f "$FILE"; then
  	chmod 440 "$FILE"
	echo -e "$SUCCESS User $user successfully added to sudoers."
	trap - ERR    # Disable trap once file validated successfully
    else
	echo -e "$ERROR Syntax error in $FILE" >&2
	rm -f "$FILE"
	EXIT=1
    fi
done

exit $EXIT
