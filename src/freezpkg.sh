#!/usr/bin/bash

set -euo pipefail

mkdir -p ~/tmp

sed -n '/^##### BEGIN pacman.conf.patch$/,/^##### END pacman.conf.patch$/{//!p}' \
    "${0:-}" > ~/tmp/pacman.conf.patch

patch /etc/pacman.conf < ~/tmp/pacman.conf.patch

exit

##### BEGIN pacman.conf.patch
--- pacman.conf	2020-07-02 13:29:39.074595085 +0200
+++ /etc/pacman.conf	2020-06-13 14:59:29.830047097 +0200
@@ -22,7 +22,7 @@
 Architecture = auto
 
 # Pacman won't upgrade packages listed in IgnorePkg and members of IgnoreGroup
-#IgnorePkg   =
+IgnorePkg   = linux-lts linux-lts-headers zfs-linux-lts zfs-linux-lts-headers zfs-utils
 #IgnoreGroup =
 
 #NoUpgrade   =
##### END pacman.conf.patch

