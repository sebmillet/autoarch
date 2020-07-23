#!/usr/bin/bash

# No 'set -o pipefail' as we use 'yes |', and the stop of yes (when makepkg
# terminates) stops the script.
set -eu

pacmanopt=${1:-}

mkdir -p ~/tmp
cd ~/tmp

echo "* ************************************** *"
echo "* INSTALLING package-query FROM GIT REPO *"
echo "* ************************************** *"
echo

rm -rf package-query
git clone https://aur.archlinux.org/package-query.git
cd package-query
    # shellcheck disable=SC2086
makepkg -si ${pacmanopt}
cd ..

echo
echo "* ******************************* *"
echo "* INSTALLING yaourt FROM GIT REPO *"
echo "* ******************************* *"
echo

rm -rf yaourt
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
    # shellcheck disable=SC2086
makepkg -f -si ${pacmanopt}

echo
echo "yaourt successfully installed."

