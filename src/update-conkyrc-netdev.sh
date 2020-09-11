#!/usr/bin/bash

set -euo pipefail

#
# In a .conkyrc file, replace occurences of default network device by another
# one.

ORIG_NETDEV=wlp2s0
CONKYRCFILES=('.conkyrc-principal' '.conkyrc-i3')

# From
#   https://unix.stackexchange.com/questions/412516/create-an-array-with-all-network-interfaces-in-bash
readarray -t interfaces < \
    <(ip l | awk -F ":" '/^[0-9]+:/{dev=$2 ; if ( dev !~ /^ lo$/) {print $2}}')
if [ ${#interfaces[@]} = 1 ]; then
    mynetdev=${interfaces[0]// /}
else
    echo "Multiples interfaces found."
    for i in "${interfaces[@]// /}" ; do echo "  $i" ; done
    echo "Which one do you want?"
    read -r mynetdev
    if [ -z "${mynetdev}" ]; then
        echo "Aborted."
        exit
    fi
fi

echo "Interface: '${mynetdev}'"

cd "${HOME}"

for f in "${CONKYRCFILES[@]}"; do
    echo "Updating in '${f}'"
    sed -i "s/${ORIG_NETDEV}/${mynetdev}/g" "${f}"
done

