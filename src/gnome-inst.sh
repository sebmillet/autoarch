#!/usr/bin/bash

set -euo pipefail

echo "Installing video driver and xorg"
pacman --noconfirm -S mesa xf86-video-intel xorg-server xorg-apps

echo
echo "Installing gnome and gnome-extra"
pacman --noconfirm -S gnome gnome-extra

