autoarch
========

The purpose of this project is to automate Arch installation with a set of
packages and configuration files to make it ready to use.

There are two stages:

1. aa.sh will install Arch on disk.
   The pre-requisite is to start PC from archiso image, then copy aa.sh and run
   it.
   To download aa.sh from a (network-enabled) archiso, execute:

   curl -O https://raw.githubusercontent.com/sebmillet/autoarch/master/src/aa.sh

   If aa.sh finds itself part of an extracted archive (INSTPUB.tgz or
   INSTPRIV.tgz, see below), then it won't download it.
   If not, then aa.sh will automatically download and extract INSTPUB.tgz from
   the latest release published on github. INSTPRIV.tgz cannot be downloaded (it
   is never published online.)

2. The use of one of INSTPUB.tgz or INSTPRIV.tgs, to install additional packages
   and implement proper configuration.
   Both archives are very close, but INSTPRIV.tgz contains extra, non-public
   stuff like configuration files containing passwords and ~/.gnupg for example.

   When extracted, they create an 'install' directory from where you can install
   and configure whatever you wish with a Makefile logic.

   Low level targets are named with two numbers (10 for basic configuration
   files, 20 to install some extra packages, etc.).

   Higher-level targets (targets triggering other targets) are:
     cli: installs and configures everything non-gui.
     gui: installs and configures everything gui.
     all: triggers both cli and gui

