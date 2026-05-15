#!/bin/bash
# configure_ssh_access.sh

source ./script_message.sh

set -euo pipefail


MODE=""
CONF_DIR="/etc/ssh/sshd_config.d"
CONF_FILE="$CONF_DIR/50-custom.conf"
NEW_CONF=""

# Mostra per pantalla l'ús correcte del script.
usage() {
    output_message INFO "USAGE: $0 --mode <bootstrap|secure>"
    exit 1
}

# Genera els paràmetres de configuració segons el mode desitjat.
generate_config() {
    case "$1" in
        bootstrap)
            cat <<EOF
PermitRootLogin prohibit-password
PasswordAuthentication yes
PubkeyAuthentication yes
EOF
            ;;
        secure)
            cat <<EOF
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
EOF
            ;;
	*)
	    output_message ERROR "Unknown --moooooooooode $1"
	    return 1
            ;;
    esac
}

# Es necessita almenys un paràmetre d'entrada
if [ $# -lt 1 ]; then
    usage
fi

# Si el primer paràmetre és --mode s'aplica el mode indicat.
# Si és qualsevol altra cosa és salta a 'usage'.
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

# Comprova que la variable MODE no és buida.
if [ -z "$MODE" ]; then
    output_message ERROR "Error: --mode is required."
    usage
fi


# Si el MODE no és secure ni bootstrap, crida usage() 
if ! NEW_CONF="$(generate_config "$MODE")"; then
    usage
fi

# Es comprova que la configuració que es vol aplicar sigui diferent a la actual.
if [ -f "$CONF_FILE" ] && diff -q <(echo "$NEW_CONF") "$CONF_FILE" >/dev/null; then
    output_message WARNING "La configuració actual ja està en mode $MODE. No s'aplica cap canvi."
    exit 2
fi


# S'aplica la nova configuració al fitxer de configuracio /etc/ssh/sshd_config.d/50-custom.conf
mkdir -p "$CONF_DIR"
echo "$NEW_CONF" > "$CONF_FILE"
output_message SUCCESS "El fitxer de configuració ha canviat a mode $MODE."


if ! sshd -t; then
    output_message ERROR "La configuració SSH no és vàlida."
    exit 2
fi


# Es reinicia el servei per fer efectiva la nova configuració.
systemctl restart ssh
output_message SUCCESS "El servidor SSH s'ha reiniciat correctament."
