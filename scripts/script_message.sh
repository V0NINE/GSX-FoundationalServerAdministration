#!/usr/bin/env bash


set -euo pipefail


# Define colors for readable script output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

ERROR_PREFIX="${RED}[x]${RESET}"
WARNING_PREFIX="${YELLOW}[!]${RESET}"
SUCCESS_PREFIX="${GREEN}[+]${RESET}"


# Print message with prefix based on level
output_message() {
    local level="$1"
    shift || true
    local message="$*"

    case "$level" in
        ERROR)
            echo -e "${ERROR_PREFIX} ${message}" >&2
            ;;
        WARNING)
            echo -e "${WARNING_PREFIX} ${message}"
            ;;
        SUCCESS)
            echo -e "${SUCCESS_PREFIX} ${message}"
            ;;
        *)
            echo "${message}"
            ;;
    esac
}
