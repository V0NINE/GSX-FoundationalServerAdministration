#!/bin/bash
# initial_configuration.sh - Essential configurations for sysadmin remote work
#
# PURPOSE:
#

USER="$1"
FILE="/etc/sudoers.d/$USER"

# ----
# Verificar que l'usuari existeix i que no esta al grup sudo ni a /etc/sudoers.d/
# ----

echo "$USER ALL=(ALL:ALL) ALL" > $FILE

# Validar sintaxi i afegir a /etc/sudoers.d
visudo -c -f $FILE
if [ $? -eq 0 ]; then
    chmod 440 $FILE
    echo "[+] Usuari $USER afegir correctament al sudoers file."
else
    echo "[!] Hi ha algun error de sintaxi al fitxer"
    rm $FILE 
    exit 1
fi

# ----
# Comprovar que openssh-server no està instal·lat
# ----

# Instal·lar openssh-server
apt update
apt-get install -y openssh-server



