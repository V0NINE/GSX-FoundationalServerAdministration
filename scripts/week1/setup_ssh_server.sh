#!/usr/bin/env bash
# setup_ssh_server.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../script_message.sh"

set -euo pipefail

SSH_PACKET="openssh-server"
SSH_SERVICE="ssh"

# Comprovar si ssh esta instalat i instal·lar-lo
if ! dpkg -l "$SSH_PACKET" | grep -q '^ii'; then 

    # APT UPDATE
    if ! apt-get -qq update >/dev/null; then
        output_message ERROR "Ha sorgit un error actualitzant les llibreries d'APT"
        exit 1
    fi

    # APT INSTALL
    if ! apt-get install -q -y "$SSH_PACKET" >/dev/null; then 
        output_message ERROR "S'ha intentat instal·lar openssh-server, però ha sorgit algun error"
        exit 1
    fi
    
    output_message SUCCESS "El paquet openssh-server s'ha instal·lat correctament"
else
    output_message WARNING "El paquet openssh-server ja està instal·lat"
fi


# Arrancar el servei (start i enable)
if ! systemctl is-enabled -q "$SSH_SERVICE"; then
    if ! systemctl enable "$SSH_SERVICE"; then
        output_message WARNING "No s'ha pogut establir el servei ssh a enable."
	exit 2
    fi	

    output_message SUCCESS "El servei ssh s'ha establert a enable."
fi

if ! systemctl is-active -q "$SSH_SERVICE"; then
    if ! systemctl start "$SSH_SERVICE"; then
        output_message ERROR "No s'ha pogut arrancar el servei ssh"
        exit 2
    fi
    
    output_message SUCCESS "S'ha arrancat el servei ssh"
fi
