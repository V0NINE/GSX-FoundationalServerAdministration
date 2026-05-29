#!/usr/bin/env bash
# script_message.sh - Centralized script output helpers

set -euo pipefail

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

INFO_PREFIX="${BLUE}[i]${RESET}"
ERROR_PREFIX="${RED}[x]${RESET}"
WARNING_PREFIX="${YELLOW}[!]${RESET}"
SUCCESS_PREFIX="${GREEN}[+]${RESET}"

output_message() {
    local level="${1:-INFO}"
    shift || true
    local message="$*"

    case "$level" in
        INFO)
            echo -e "${INFO_PREFIX} ${message}"
            ;;
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

require_root() {
    if [ "${EUID}" -ne 0 ]; then
        output_message ERROR "This script must be run as root. Use sudo."
        exit 1
    fi
}
