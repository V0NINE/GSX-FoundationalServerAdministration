#!/bin/bash
# initial_configuration.sh - Essential configurations for sysadmin remote work
#
# PURPOSE:
#

EXIT=0

# Definició de colors per millorar la llegibilitat de l'output dels scripts
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

if [ $# -eq 0 ]; then
    echo -e "$RED[x]$RESET S'ha de passar al menys un usuari per paràmetre."
    exit -1
fi

for user in "$@"; do echo
    
    FILE="/etc/sudoers.d/$user"

    # Verifica que l'usuari existeix i que no esta al grup sudo ni a /etc/sudoers.d/
    if ! id "$user"  &> /dev/null; then
	echo -e "$YELLOW[!]$RESET L'usuari $user no existeix"
	continue
    fi

    if id -nG "$user" | grep -wq sudo; then
	echo -e "$YELLOW[!]$RESET L'usuari $user ja és al grup sudo"
	continue
    fi

    if [ -f "$FILE" ]; then
	echo -e "$YELLOW[!]$RESET L'usuari $user ja està al directori sudoers.d"
	continue
    fi

    echo "$user ALL=(ALL:ALL) ALL" > "$FILE"

    # Validar sintaxi i afegir a /etc/sudoers.d
    if visudo -c -f "$FILE"; then
  	chmod 440 "$FILE"
	echo -e "$GREEN[+]$RESET Usuari $user afegit correctament al sudoers file."
    else
	echo -e "$RED[x]$RESET Error de sintaxi al fitxer $FILE"
	rm -f "$FILE"
	EXIT=1
    fi
done

exit $EXIT
