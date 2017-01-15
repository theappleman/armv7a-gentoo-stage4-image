#!/bin/bash

if test "$#" = 0; then
	echo "$0 <img> <stage3> [<stage4/>...]" >&2
	exit 1
fi
gf=$(which guestfish)

img=$1
stage=$2
shift 2

for dir in $@; do
	(cd "$dir"; tar c --owner=0 --group=0 .)
done | "$gf" \
	-N "$img"=bootroot:vfat:ext4:1536M:256M:mbr -- \
	set-label /dev/sda1 BOOT : \
	set-label /dev/sda2 ROOT : \
	mount /dev/sda2 / : \
	tar-in "$stage" / compress:bzip2 : \
	mount /dev/sda1 /boot : \
	-tar-in - / : \
	umount /boot : umount / : \
	resize2fs-M /dev/sda2
