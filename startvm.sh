#!/usr/bin/bash

set -euo pipefail

cd local

qemu-system-x86_64 -boot d \
    -rtc base=utc \
    -enable-kvm -m 2048 \
    -drive file=inc,format=qcow2 \
    -drive if=pflash,format=raw,readonly,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=my_uefi_vars.fd \
    -cdrom archlinux-2020.07.01-x86_64.iso \
    &
