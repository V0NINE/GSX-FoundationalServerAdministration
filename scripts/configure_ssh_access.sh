#!/bin/bash
# configure_ssh_access.sh

source ./script_message.sh

set -euo pipefail


MODE=""


usage() {
    output_message INFO "USAGE: $0 --mode <bootstrap|secure>"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

case "$1" in
    --mode)
        shift
        MODE="${1:-}"
        ;;
    -h|--help)
        usage
        ;;
    *)
        output_message ERROR "Unknown argument: $1"
        usage
        ;;
esac

if [ -z "$MODE" ]; then
    output_message ERROR "Error: --mode is required."
    usage
fi

case "$MODE" in
    bootstrap)
	output_message SUCCESS "BOOTSTRAP mode"
        ;;
    secure)
	output_message SUCCESS "SECURE mode"
        ;;
    *)
	output_message ERROR "Unknown --mode ${MODE}"
	usage
	;;
esac
