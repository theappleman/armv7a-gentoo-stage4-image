#!/bin/bash

set -eu

if test "$#" -lt 2; then
	echo "$0 <img> <stage3> <stage4/>" >&2
	exit 1
fi

gf=(
	$(which guestfish)

	# create mbr formatted boot&root
	-N "$1"=bootroot:vfat:ext4:1920M:16M:mbr --

	set-label /dev/sda1 BOOT :
	set-label /dev/sda2 ROOT :

	mount /dev/sda2 / :

	# unpack stage tarball
	tar-in "$2" / compress:bzip2 :

	mount /dev/sda1 /boot :
	# copy the provided overlay
	-tar-in - / :

	# copy boot files
	# kernel
	copy-in ${KDIR}/arch/arm/boot/uImage /boot :

	# dtb
	copy-in ${KDIR}/arch/arm/boot/dts/${DTB} /boot :
	mv /boot/${DTB} /boot/devicetree.dtb :

	# fpga bitstream
	copy-in ${FPGA}/parallella_e16_${VERSION}_gpiose_${ZYNQ}.bit.bin /boot :
	mv /boot/parallella_e16_${VERSION}_gpiose_${ZYNQ}.bit.bin /boot/parallella.bit.bin :

	# kernel modules
	-copy-in ${KDIR}/tar-install/lib /
)

(cd "$3"; tar c --owner=0 --group=0 .) | ${gf[*]}
