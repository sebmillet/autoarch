#!/usr/bin/bash

# Copyright 2020 Sébastien Millet, milletseb@laposte.net

# aa.sh
# Automatic Arch Installation Script

#
#  Copyright 2020 Sébastien Millet
#
#  aa.sh is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  aa.sh is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses>.

#
# ABOUT NETWORK START
#
#   On ethernet networks with DHCP, network connectivity is available out of the
#   box. Therefore the simplest is to leave it as is at install time.
#
#   If using a Wifi network, then you have to:
#
#   1- Set $do_network to y
#
#   2- Update $netctl_cfg with your Wifi data. Consider updating the variables:
#
#      * Interface (check with command 'ip link show')
#        THERE IS A PITFALL HERE
#        If you check the interface name on an already installed Linux, you'll
#        see something like 'wlp2s0' (this one means: wireless card on PCI bus
#        2, slot 0).
#        archiso does not enforce the 'Predictable Network Interface Names'
#        rules and you'll get the default name, typically, it'll be:
#
#        wlan0
#
#        When booting on your installed Arch Linux, your wireless card name will
#        follow the aforementioned rules, that'll require updating the
#        corresponding netctl profile file, as per this script it'll be
#
#        /etc/netctl/main
#
#      * ESSID (self-explanatory)
#
#      * Key (your ESSID' passphrase)
#

# TODO
#   Manage case when there is no swap
#   Manage BIOS (instead of UEFI) system boot
#   Network behind proxy

set -euo pipefail

# CONFIG {{{

do_loadkeys=y
do_network=n
do_timedatectl=y
do_disk=y
do_mirrorlist=y
do_pacstrap=y
do_fstab=y

interactive=y

keymap=fr-latin1

netctl_profile=main
netctl_cfg=$(cat << end-of-file
Description='Main Connection'
Interface=wlan0
Connection=wireless
Security=wpa
IP=dhcp
ESSID='THE ESSID OF MY WIFI NETWORK'
Key='THE PASSPHRASE FOR MY WIFI NETWORK'
end-of-file
)
    # Wait time between "netctl start" and "ping" test, in seconds
netctl_wait=15
server_to_ping='archlinux.org'

    #   y: wipe all disk
    #   n: wipe only devdata (leave top level partitionning untouched)
    #      Actually the LVM inside devdata (if using LVM...) will be
    #      partitionned, still.
dopart=y
    # Disk to partition, example: /dev/sda
devdisk=
efipartname="EFI System Partition"
lvmpartname="main"
    # EFI partition, example: /dev/sda1
devefi=
efisizemb=500
    # Main volumes
devswap=
    # If left empty, is set to half of physical memory
swapsizemb=
devdata=
swapname=swap
rootname=rootfs
    # Encrypt devdata?
    #   y: encrypt devdata and create swap and rootfs underneath (with LVM)
    #   n: use devdata in plain
docrypt=y
    # VERY BAD PRACTICE TO WRITE A PASSWORD HERE! YOU'VE BEEN WARNED.
cryptpwd="1234"
cryptmappername=clvm
    # LVM
vgname=vol

mirrors_country=France
mirrors_linerange='2,5'
    # Number of mirrors at the end of the update. {2,5} has 4 elements.
linerange_size=4

pacstrap_install="base linux linux-firmware"

tz=Europe/Paris
loc_list=('en_US.UTF-8' 'fr_FR.UTF-8')

# CONFIG }}}

# REVERT DISK OPERATIONS {{{
if [ "${1:-}" == "stop" ]; then

    set +e
    if [ -d "/mnt/boot/EFI" ]; then
        umount "/mnt/boot"
    fi
    swapoff -a
    umount "/mnt"
    if [ "${docrypt}" == "y" ]; then
        vgremove -f "${vgname}"
        cryptsetup close "${cryptmappername}"
    fi
        # Not useful... done in case extra code would be added below
    set -e

    exit 0
fi
# REVERT DISK OPERATIONS }}}
# LOADKEYS {{{

if [ "${do_loadkeys}" == "y" ] && [ -e .do_loadkeys_done ]; then
    echo ".. LOADKEYS: already done, skipped"
    do_loadkeys=n
fi
if [ "${do_loadkeys}" == "y" ]; then

loadkeys "${keymap}"

echo "== LOADKEYS: OK"
touch .do_loadkeys_done
fi # do_loadkeys }}}
# VERIFYBOOTMODE {{{

if [ ! -d /sys/firmware/efi/efivars ]; then
    echo "Error: not started in UEFI mode."
    exit 13
fi

# VERIFYBOOTMODE }}}
# NETWORK {{{

if [ "${do_network}" == "y" ] && [ -e .do_network_done ]; then
    echo ".. NETWORK: already done, skipped"
    do_network=n
fi
if [ "${do_network}" == "y" ]; then

echo "${netctl_cfg}" > "/etc/netctl/${netctl_profile}"
iface=$(echo "${netctl_cfg}" | grep -i "^interface\s*=" | sed 's/.*= *//')
if [ -z "${iface}" ]; then
    echo "Error: could not work out network interface from \$netctl_cfg."
    exit 11
fi

echo "Will try to activate network"

set +e
netctl stop-all
ip link set "${iface}" down
set -e
sleep 1

echo "Mounting network profile: ${netctl_profile}"
netctl start "${netctl_profile}"
sleep "${netctl_wait}"
    # No test, nothing: we just do a ping and if it fails, it'll produce a non
    # null return code that'll stop the script.
ping -c1 "${server_to_ping}"

echo "== NETWORK: OK"
touch .do_network_done
fi # do_network }}}
# TIMEDATECTL {{{

if [ "${do_timedatectl}" == "y" ] && [ -e .do_timedatectl_done ]; then
    echo ".. TIMEDATECTL: already done, skipped"
    do_timedatectl=n
fi
if [ "${do_timedatectl}" == "y" ]; then

timedatectl set-ntp true

echo "== TIMEDATECTL: OK"
touch .do_timedatectl_done
fi # do_timedatectl }}}
# DISK {{{

if [ "${do_disk}" == "y" ] && [ -e .do_disk_done ]; then
    echo ".. DISK: already done, skipped"
    do_disk=n
fi
if [ "${do_disk}" == "y" ]; then

efiformat=n

if [ "${dopart}" == "y" ] && [ -n "${devdata}" ]; then
    echo "Error: when \$dopart is set to 'y', \$devdata must be empty"
    exit 11
fi

if [ "${dopart}" == "y" ] && [ -n "${devefi}" ]; then
    echo "Error: when \$dopart is set to 'y', \$devefi must be empty"
    exit 11
fi

if [ "${dopart}" != "y" ] && [ -n "${devdisk}" ]; then
    echo "Error: when \$dopart is set to 'n', \$devdisk must be empty"
    exit 11
fi

if [ "${docrypt}" == "y" ] && [ -n "${devswap}" ]; then
    echo "Error: when \$docrypt is set to 'y', \$devswap must be empty"
    exit 11
fi

if [ -z "${swapsizemb}" ]; then
    physicalmemorykb=$(grep MemTotal /proc/meminfo \
        | sed 's/^.*\s\([0-9]\+\).*$/\1/')
    swapsizemb=$(( physicalmemorykb / 2 / 1024 ))
fi
echo "EFI Size: ${efisizemb} mB"
echo "Swap size: ${swapsizemb} mB"
swapendmb=$(( swapsizemb + efisizemb ))
echo "Swap end: ${swapendmb} mB"

if [ "${dopart}" == "y" ]; then

    if [ -z "${devdisk}" ]; then
        if [ "${interactive:-y}" == "n" ]; then
            echo "Error: interactive mode is off, therefore the disk to install"
            echo "Arch Linux on must be defined."
            echo "Find the variable \$devdisk in this script and update it."
            exit 20
        fi
        echo "Disk to install Arch Linux on, example: /dev/sda"
        echo -n "Default: [] "
        read -r devdisk
    fi

    if [ -z "${devdisk}" ]; then
        echo "Aborted."
        exit 1
    fi

    echo "Device Arch Linux will be installed on: ${devdisk}"

    set +e

    v=$(parted -m -s "${devdisk}" -- unit gib p 2> /dev/null);
    if ! echo "${v}" | head -n 1 | grep -q "^BYT;$"; then
        echo "Error: unable to parse output of parted"
    fi

    set -e

    nbparts=$(echo "${v}" | sed '1,2d' | wc -l)

    if [ "${nbparts}" -ge 1 ]; then
        echo "${devdisk} already contains ${nbparts} partition(s)."
        echo "If you continue, everything will be wiped. Continue? (y/N)"
        resp=y
        if [ "${interactive:-y}" != "n" ]; then
            echo -n "Default: [N] "
            read -r resp
        fi
        if [ "${resp}" != "y" ]; then
            echo "Aborted."
            exit 1
        fi
    fi

    if [ "${docrypt}" == "y" ]; then
        parted -m -s "${devdisk}" -- mklabel gpt \
            mkpart '"'"${efipartname}"'"' 0% "${efisizemb}"MiB \
            mkpart '"'"${lvmpartname}"'"' "${efisizemb}"MiB 100% \
            toggle 1 esp \
            toggle 2 lvm

        devdata="${devdisk}2"
    else
        parted -m -s "${devdisk}" -- mklabel gpt \
            mkpart '"'"${efipartname}"'"' 0% "${efisizemb}"MiB \
            mkpart '"'"${swapname}"'"' "${efisizemb}"MiB "${swapendmb}"MiB \
            mkpart '"'"${rootname}"'"' "${swapendmb}"MiB 100% \
            toggle 1 esp \
            toggle 2 swap

        devswap="${devdisk}2"
        devdata="${devdisk}3"
        devrootfs="${devdisk}3"
    fi

    efiformat=y

else

    if [ -z "${devdata}" ]; then
        if [ "${interactive:-y}" == "n" ]; then
            echo "Error: interactive mode is off, therefore the partition to"
            echo "install Arch Linux on must be defined."
            echo "Find the variable \$devdata in this script and update it."
            exit 20
        fi
        echo "Partition to install Arch Linux on, example: /dev/sda2"
        echo -n "Default: [] "
        read -r devdata

        if [ -z "${devdata}" ]; then
            echo "Aborted."
            exit 1
        fi

        set +e
        if ! echo "${devdata}" | grep "[0-9]$"; then
            echo "Error: you must choose a partition (ending with a number)"
            exit 9
        fi
        set -e
    fi
    devrootfs="${devdata}"

fi

if [ -z "${devdisk}" ]; then
    # bash does not seem to implement '$' (end of string) in regex patterns
    # therefore it won't work with ${var/pat/rep} logic.
    # shellcheck disable=SC2001
    vv=$(echo "${devdata}" | sed 's/[0-9]\+$//')
else
    vv="${devdisk}"
fi

set +e
efipartnum=$(parted -m -s "${vv}" -- unit gib p \
    | grep ":[^:]*esp[^:]*$" \
    | awk -F: '{ print $1; }')
set -e
if [ -z "${efipartnum}" ]; then
    echo "Error: unable to work out the EFI partition number."
    exit 2
fi
guesseddevefi="${vv}${efipartnum}"
if [ -n "${devefi}" ]; then
    if [ "${devefi}" != "${guesseddevefi}" ]; then
        echo "Error: enforced \$devefi (${devefi}) seems not OK"
        exit 3
    fi
else
    devefi="${guesseddevefi}"
fi

echo "EFI partition: ${devefi}"

if [ "${devefi}" == "${devdata}" ]; then
    echo "Error: \$devefi (${devefi}) is equal to \$devdata (${devdata})."
    exit 10
fi

if [ "${efiformat}" == "y" ]; then
    echo "Formatting ${devefi}"
    mkfs.vfat -F 32 -n "EFI" "${devefi}"
fi

mkdir -p "/tmpefi"

set +e
if ! mount "${devefi}" "/tmpefi"; then
    echo "Error: unable to mount EFI partition in ${devefi}"
    exit 4
fi
set -e

if [ "${efiformat}" == "y" ]; then
    mkdir "/tmpefi/EFI"
fi

set +e
    # Defensive programming: not a typo. We created EFI and below, we are
    # checking existence of efi. Volume must be of type FAT that is not
    # case-sensitive.
[ -d "/tmpefi/efi" ]
t=$?
set -e

umount "/tmpefi"
rmdir "/tmpefi"

if [ "${t}" -ne "0" ]; then
    echo "Error: EFI partition does not contain EFI folder"
    exit 5
fi

if [ "${docrypt}" != "y" ]; then

    set +e
    swappartnum=$(parted -m -s "${vv}" -- unit gib p \
        | grep ":[^:]*swap[^:]*$" \
        | awk -F: '{ print $1; }')
    set -e
    if [ -z "${swappartnum}" ]; then
        echo "Error: unable to work out the swap partition number."
        exit 6
    fi
    guesseddevswap="${vv}${swappartnum}"
    if [ -n "${devswap}" ]; then
        if [ "${devswap}" != "${guesseddevswap}" ]; then
            echo "Error: enforced \$devswap (${devswap}) seems not OK"
            exit 7
        fi
    else
        devswap="${guesseddevswap}"
    fi

else

    echo "Encrypting volume: ${devdata}"

    if [ -z "${cryptpwd}" ]; then
        cryptsetup luksFormat --batch-mode --type luks2 "${devdata}"
    else
        echo -n "${cryptpwd}" \
        | cryptsetup luksFormat --batch-mode --type luks2 "${devdata}" -
    fi

    echo "Opening encrypted volume ${devdata} as ${cryptmappername}"
    if [ -z "${cryptpwd}" ]; then
        cryptsetup open "${devdata}" "${cryptmappername}"
    else
        echo -n "${cryptpwd}" \
        | cryptsetup open "${devdata}" "${cryptmappername}" -
    fi

    pvname="/dev/mapper/${cryptmappername}"
    pvcreate "${pvname}"
    vgcreate "${vgname}" "${pvname}"

    lvcreate -L "${swapsizemb}"mib "${vgname}" -n "${swapname}"
    lvcreate -l '100%FREE' "${vgname}" -n "${rootname}"

    devswap="/dev/${vgname}/${swapname}"
    devrootfs="/dev/${vgname}/${rootname}"
fi

echo "swap partition: ${devswap}"

if [ "${devswap}" == "${devefi}" ] \
    || [ "${devswap}" == "${devrootfs}" ] \
    || [ "${devefi}" == "${devrootfs}" ]; then
    echo "Error: some of EFI, swap and rootfs are using the same partition."
    exit 8
fi

mkswap "${devswap}"
swapon "${devswap}"

if [ "${interactive:-y}" != "n" ]; then
    mkfs.ext4 "${devrootfs}"
else
    echo "y" | mkfs.ext4 "${devrootfs}"
fi
mount "${devrootfs}" /mnt

mkdir /mnt/boot
mount "${devefi}" /mnt/boot

echo "== DISK: OK"
touch .do_disk_done
fi # do_disk }}}
# MIRRORLIST {{{

if [ "${do_mirrorlist}" == "y" ] && [ -e .do_mirrorlist_done ]; then
    echo ".. MIRRORLIST: already done, skipped"
    do_mirrorlist=n
fi
if [ "${do_mirrorlist}" == "y" ]; then

# FIXME
# ABOUT THE WAY I CHOOSE MIRRORS
# The below logic is actually very similar to what I tend to do manually: I
# select a few servers of my country manually, leave them active and comment out
# all others. I sometimes activate a few others of different countries nearby,
# but it is not done below. Obviously this is relevant only if I'm the only one
# to do this! If this script was to be used by other people, a better logic
# (like, the use of reflector) had better be implemented.
# Although this is an amazingly broken approach, it has two advantages: no
# package installation pre-requisite and no network connection needed.

# mirror selector of the (very) poor man.

if [ ! -f mirrorlist.orig ]; then
    cp -ip /etc/pacman.d/mirrorlist mirrorlist.orig
fi
sed 's/^server/#&/i' mirrorlist.orig > mirrorlist.tmp
{   echo "##################################"; \
    echo "## Automatically added by aa.sh ##"; \
    echo "##################################"; } \
    >> mirrorlist.tmp
cp -p mirrorlist.tmp /etc/pacman.d/mirrorlist
sed ':a;N;$!ba;s/\(## '"${mirrors_country}"'\n\)#/\1/ig' mirrorlist.tmp \
    | grep '^Server' \
    | sed -n "${mirrors_linerange}"'p' \
    | sed 's/^.*$/## '"${mirrors_country}"'\n&/g' \
    >> /etc/pacman.d/mirrorlist
rm mirrorlist.tmp

countmirrors=$(grep -ic "^server" < /etc/pacman.d/mirrorlist)
if [ "${countmirrors}" -ne "${linerange_size}" ]; then
    echo "Error: something went wrong in /etc/pacman.d/mirrorlist file update."
    echo "       The active line count is ${countmirrors}."
    echo "       The active line count should be ${linerange_size}."
    exit 14
fi

echo "== MIRRORLIST: OK"
touch .do_mirrorlist_done
fi # do_mirrorlist }}}
# PACSTRAP {{{

if [ "${do_pacstrap}" == "y" ] && [ -e .do_pacstrap_done ]; then
    echo ".. PACSTRAP: already done, skipped"
    do_pacstrap=n
fi
if [ "${do_pacstrap}" == "y" ]; then

if ! mount | grep '\s/mnt\s'; then
    echo "Error: /mnt is not mounted."
    exit 12
fi

    # shellcheck disable=SC2086
pacstrap /mnt ${pacstrap_install}

echo "== PACSTRAP: OK"
touch .do_pacstrap_done
fi # do_pacstrap }}}
# FSTAB {{{

if [ "${do_fstab}" == "y" ] && [ -e .do_fstab_done ]; then
    echo ".. FSTAB: already done, skipped"
    do_fstab=n
fi
if [ "${do_fstab}" == "y" ]; then

if [ ! -e fstab.orig ]; then
    cp -ip /mnt/etc/fstab fstab.orig
fi

genfstab -U /mnt >> /mnt/etc/fstab

echo "== FSTAB: OK"
touch .do_fstab_done
fi # do_fstab }}}

sep=
loc_regex=
for l in "${loc_list[@]}"; do
    loc_regex="${loc_regex}${sep}${l}"
    sep='\|'
done
loc_nb="${#loc_list[@]}"

cat > /mnt/subscript.sh << end-of-file
#!/usr/bin/bash

set -euo pipefail

if [ ! -f /usr/share/zoneinfo/${tz} ]; then
    echo "File /usr/share/zoneinfo/${tz} does not exist"
    exit 1
fi
ln -sf /usr/share/zoneinfo/${tz} /etc/localtime

hwclock --systohc

if [ ! -e /root/locale.gen.orig ]; then
    cp -ip /etc/locale.gen /root/locale.gen.orig
fi
cp -p /root/locale.gen.orig /etc/locale.gen
sed -i 's/^#\(${loc_regex}\)/\1/' /etc/locale.gen
nb=\$(grep -c "^[^#]" /etc/locale.gen)
if [ "\${nb}" -ne "${loc_nb}" ]; then
    echo "Error: inconsistent result while updating /etc/locale.gen"
    echo "Probable cause: non-existent locale in \\\$loc_list"
    exit 2
fi

echo "Done"
end-of-file

chmod +x /mnt/subscript.sh
arch-chroot /mnt /subscript.sh

echo "Au revoir"

# vim: ts=4:sw=4:et:tw=80:fmr={{{,}}}:fdm=marker:
