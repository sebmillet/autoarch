#!/usr/bin/bash

# Copyright 2020 Sébastien Millet, milletseb@laposte.net

set -euo pipefail

file=${1:-}

if [ -z "${file}" ] || [ "${file}" == "-h" ]; then
    echo "Usage:"
    echo "  manage-includes.sh FILE"
    echo "Inside FILE, replace lines of the form"
    echo '#!include "filename"'
    echo "with the content of filename."
    exit 1
fi

# Trick to replace a pattern with file content was found here:
#   [1] https://unix.stackexchange.com/questions/49377/substitute-pattern-within-a-file-with-the-content-of-other-file/49438#49438
while grep -q '^#!include\s*"[^"]\+"' "${file}"; do
    file_included=$(grep -m 1 '^#!include\s*"[^"]\+"' "${file}" \
                    | sed 's/^[^"]*"\([^"]*\)"/\1/')
    file_included=$(sh -c "echo ${file_included}")
    if [ ! -r "${file_included}" ]; then
        echo "Error: file '${file}': included file '${file_included}'" \
             "does not exist or is not readable"
        exit 2
    fi
    line_where_to_substitute=$(grep -m 1 -n '^#!include\s*"[^"]\+"' "${file}" \
                               | cut -f1 -d:)

        # WARNING
        #   Below, the newline character is part of the command (and it is
        #   normal the first line does not end with a backslash), see URL [1]
        #   above.
    sed -e "${line_where_to_substitute}"' {r '"${file_included}"'
        d}' -i "${file}"
done

