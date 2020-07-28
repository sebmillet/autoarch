#!/usr/bin/bash

set -euo pipefail

cd local

rm -f inc
qemu-img create -f qcow2 -b disk inc
cp -i /usr/share/ovmf/x64/OVMF_VARS.fd my_uefi_vars.fd

