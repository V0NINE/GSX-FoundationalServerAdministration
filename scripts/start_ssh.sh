#!/bin/bash
# start_ssh.sh - 
#
# PURPOSE:
#

# Definició de colors per millorar la llegibilitat de l'output dels scripts
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

ERROR="$RED[x]$RESET"
WARNING="$YELLOW[!]$RESET"
SUCCESS="$GREEN[+]$RESET"

SSH_PACKET="openssh-server"
SSH_SERVICE="ssh"


# Comprovar si ssh esta instalat i instal·lar-lo
if ! dpkg -s "$SSH_PACKET" &>/dev/null; then 

    # APT UPDATE
    if ! apt-get -qq update; then
	echo -e "$ERROR Ha sorgit un error actualitzant les llibreries d'APT"
	exit 1
    fi

    # APT INSTALL
    if ! apt-get install -q -y "$SSH_PACKET"; then 
	echo -e "$ERROR S'ha intentat instal·lar openssh-server, però ha sorgit algun error"
	exit 1
    fi
    
    echo -e "$SUCCESS El paquet openssh-server s'ha instal·lat correctament"
else
    echo -e "$WARNING El paquet openssh-server ja està instal·lat"
fi


# Arrancar el servei (start i enable)
if ! systemctl is-enabled -q "$SSH"; then
    if ! systemctl enable "$SSH"; then
	echo -e "$WARNING No s'ha pogut establir el servei ssh a enable."
    fi	
fi

if ! systemctl is-active -q "$SSH"; then
    if ! systemctl start "$SSH"; then
	echo -e "$ERROR No s'ha pogut arrancar el servei ssh"
	exit 2
    fi
fi
