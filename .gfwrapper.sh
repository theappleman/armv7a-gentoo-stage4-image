#!/bin/bash

if test "$#" = 0; then
	echo "$0 <img> <stage3> <stage4/>" >&2
	exit 1
fi
gf=$(which guestfish)

(cd "$3"; tar c --owner=0 --group=0 .) | "$gf" \
	-N "$1"=bootroot:vfat:ext4:1920M:16M:mbr -- \
	set-label /dev/sda1 BOOT : \
	set-label /dev/sda2 ROOT : \
	mount /dev/sda2 / : \
	tar-in "$2" / compress:bzip2 : \
	mount /dev/sda1 /boot : \
	-tar-in - / : \
	umount /boot : umount / : \
	resize2fs-M /dev/sda2
