#!/usr/bin/bash

# No 'set -o pipefail' as we use 'yes |', and the stop of yes (when makepkg
# terminates) stops the script.
set -eu

export LANG=''
mkdir ~/tmp
cd ~/tmp

echo "* ************************************** *"
echo "* INSTALLING package-query FROM GIT REPO *"
echo "* ************************************** *"
echo

git clone https://aur.archlinux.org/package-query.git
cd package-query
yes | makepkg -si
cd ..

echo
echo "* ******************************* *"
echo "* INSTALLING yaourt FROM GIT REPO *"
echo "* ******************************* *"
echo

git clone https://aur.archlinux.org/yaourt.git
cd yaourt
yes | makepkg -si

echo
echo "yaourt successfully installed."

