# getin.sh

#
# Download latest release of INSTPUB.tgz from github and extract it.
#
# Copyright 2020 Sébastien Millet, milletseb@laposte.net
#
# Usage:
#   sh getin.sh
#

set -euo pipefail

file=INSTPUB.tgz

if [ -e "${file}" ]; then
    echo "File '${file}' exists and will be overwritten."
fi
if [ -d install ]; then
    echo "Directory 'install' exists and will be overwritten."
fi
if [ -e "${file}" ] || [ -d install ]; then
    read -p "Continue? (y/N) " -r resp
    if [ "${resp}" != "y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

rm -f "${file}"
rm -rf install

echo
echo "-- Downloading ${file}"
curl -s "https://api.github.com/repos/sebmillet/autoarch/releases/latest" \
    | grep "browser_download_url.*${file}" \
    | sed 's/^.*browser_download_url":\s*"\([^"]\+\)"$/\1/' \
    | xargs curl -L --output "${file}"

echo
echo "-- Extracting ${file} into 'install' directory"
tar -zxvf "${file}"

