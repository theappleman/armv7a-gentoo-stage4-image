#!/bin/bash

if test "$#" = 0; then
	echo "$0 <img> <stage3> <stage4/>" >&2
	exit 1
fi
gf=$(which guestfish)

(cd "$3"; tar c --owner=0 --group=0 .) | "$gf" \
	-N "$1"=bootroot:vfat:ext4:1280M:256M:mbr -- \
	set-label /dev/sda1 BOOT : \
	mount /dev/sda2 / : \
	tar-in "$2" / compress:bzip2 : \
	mount /dev/sda1 /boot : \
	-tar-in - / : \
	umount /boot : umount / : \
	fsck ext4 /dev/sda2 : \
	resize2fs-M /dev/sda2
