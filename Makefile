STAGE4 = $(shell find stage4/ -type f)

parallella.img.bz2: parallella.img
	bzip2 -kf $<

parallella.img: $(STAGE4) stage3-armv7a_hardfp-latest.tar.bz2 stage4/boot/parallella.bit.bin stage4/boot/uImage stage4/boot/devicetree.dtb authorized_keys
	@test -d stage4/boot || mkdir -p stage4/boot
	(cd stage4; tar c --owner=0 --group=0 .) | guestfish \
	-N $@=bootroot:vfat:ext4:1280M:256M:mbr -- \
	set-label /dev/sda1 BOOT : \
	mount /dev/sda2 / : \
	tar-in stage3-armv7a_hardfp-latest.tar.bz2 / compress:bzip2 : \
	mount /dev/sda1 /boot : \
	-tar-in - / : \
	mkdir /root/.ssh : chmod 0700 /root/.ssh : \
	copy-in authorized_keys /root/.ssh : \
	chmod 0600 /root/.ssh/authorized_keys : \
	chown 0 0 /root/.ssh/authorized_keys : \
	umount /boot : umount / : \
	fsck ext4 /dev/sda2

stage4/boot/parallella.bit.bin: elink2_e16_headless_gpiose_7010.bit.bin
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage4/boot/uImage: uImage
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage4/boot/devicetree.dtb: zynq-parallella1-headless.dtb
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage3-armv7a_hardfp-latest.tar.bz2:
	@echo Download the tarball from the following url and name it $@:
	@echo http://distfiles.gentoo.org/releases/arm/autobuilds/current-stage3-armv7a_hardfp/
	@exit 1
