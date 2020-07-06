#!/usr/bin/bash

set -euo pipefail

echo "Installing i3"
pacman --noconfirm -S i3-wm hsetroot i3lock xautolock numlockx otf-font-awesome dmenu

echo "Installing alttab from yaourt"
yaourt -a alttab-git

echo "Installing bumblebee-status from yaourt"
yaourt -a bumblebee-status

echo "Installing j4-dmenu-desktop from yaourt"
yaourt -a j4-dmenu-desktop

