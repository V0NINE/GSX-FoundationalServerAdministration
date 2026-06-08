#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

require_root

PACKAGES=(
    procps
    psmisc
    htop
    sysstat
    stress-ng
)

output_message INFO "Installing Week 3 process and monitoring tools..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACKAGES[@]}"

output_message SUCCESS "Week 3 tools installed."
