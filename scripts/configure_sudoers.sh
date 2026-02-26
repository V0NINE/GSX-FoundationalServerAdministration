#!/bin/bash
# configure_sudoers.sh - Add a list of user to sudoers
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

EXIT=0

if [ $# -eq 0 ]; then
    echo -e "$ERROR S'ha de passar al menys un usuari per paràmetre."
    exit -1
fi

for user in "$@"; do echo
    
    FILE="/etc/sudoers.d/$user"

    # Verifica que l'usuari existeix i que no esta al grup sudo ni a /etc/sudoers.d/
    if ! id -un "$user"  &> /dev/null; then
	echo -e "$WARNING L'usuari $user no existeix"
	continue
    fi

    if id -nG "$user" | grep -wq sudo; then
	echo -e "$WARNING L'usuari $user ja és al grup sudo"
	continue
    fi

    if [ -f "$FILE" ]; then
	echo -e "$WARNING L'usuari $user ja està al directori sudoers.d"
	continue
    fi

    echo "$user ALL=(ALL) ALL" > "$FILE"

    # Validar sintaxi i afegir a /etc/sudoers.d
    if visudo -c -f "$FILE"; then
  	chmod 440 "$FILE"
	echo -e "$SUCCESS Usuari $user afegit correctament al sudoers file."
    else
	echo -e "$ERROR Error de sintaxi al fitxer $FILE"
	rm -f "$FILE"
	EXIT=1
    fi
done

exit $EXIT
