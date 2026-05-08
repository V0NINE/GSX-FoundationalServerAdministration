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


# Import structured log messages script
source ./script_message.sh

EXIT=0


set -euo pipefail

if [ $# -eq 0 ]; then
    output_message ERROR "At least one username is required."
    exit -1
fi

cleanup() {
    local f="$1"
    output_message WARNING "Cleanup: removed $f."
    rm -f "$f"
}

# For each provided username
for user in "$@"; do echo
    
    FILE="/etc/sudoers.d/$user"

    # Ensure user exists and is not in sudo group or /etc/sudoers.d/
    # /----
    if ! id -un "$user"  &> /dev/null; then
	output_message WARNING "User $user does not exist."
	continue
    fi

    if id -nG "$user" | grep -wq sudo; then
	output_message WARNING "User $user is already in sudo group."
	continue
    fi

    if [ -f "$FILE" ]; then
	output_message WARNING "User $user is alreay in sudoers.d."
	continue
    fi
    # \----

    # Create temporary sudoers file and setup cleanup in case of error
    echo "$user ALL=(ALL) ALL" > "$FILE"

    trap "cleanup '$FILE'" ERR

    output_message INFO "Adding $user..."

    # Validate syntax, then add to /etc/sudoers.d
    if visudo -c -f "$FILE"; then
  	chmod 440 "$FILE"
	output_message SUCCESS "User $user successfully added to sudoers."
	trap - ERR    # Disable trap once file validated successfully
    else
	output_message ERROR "Syntax error in $FILE"
	rm -f "$FILE"
	EXIT=1
    fi
done

exit $EXIT
