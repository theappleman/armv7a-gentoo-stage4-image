STAGE4 = $(shell find stage4/ -type f)
VERSION ?= microserver
BOARD ?= spring

%.img.bz2: %.img
	bzip2 -kfp $<
	@echo
	touch $@

stage4/boot/%: %
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

parallella.img: stage3-armv7a_hardfp-latest.tar.bz2 stage4/boot/parallella.bit.bin stage4/boot/uImage stage4/boot/devicetree.dtb $(STAGE4)
	./.gfwrapper.sh $@ $< stage4 || rm -f $@

omaha.img: stage3-armv7a_hardfp-latest.tar.bz2 stage4/boot/omaha.kpart $(STAGE4)
	./.gfomaha.sh $@ $< stage4 || rm -f $@

stage4/boot/parallella.bit.bin: parallella_e16_$(VERSION)_gpiose_7010.bit.bin
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage4/boot/devicetree.dtb: zynq-parallella-$(VERSION).dtb
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage3-armv7a_hardfp-latest.tar.bz2:
	export getpath=$$(wget -q -O- http://distfiles.gentoo.org/releases/arm/autobuilds/latest-stage3-armv7a_hardfp.txt | awk 'NR==3{print$$1}'); \
	wget -c http://distfiles.gentoo.org/releases/arm/autobuilds/$$getpath; \
	ln -s $$(basename $$getpath) $@

$(BOARD).itb: omaha/$(BOARD).its omaha/kernel/arch/arm/boot/zImage $(wildcard omaha/kernel/arch/arm/boot/dts/*-$(BOARD).dtb)
	mkimage -f $< $@

omaha.kpart: $(BOARD).itb cmdline
	vbutil_kernel \
		--version 1 \
		--pack $@ \
		--arch arm \
		--keyblock /usr/share/vboot/devkeys/kernel.keyblock \
		--signprivate /usr/share/vboot/devkeys/kernel_data_key.vbprivk \
		--config cmdline \
		--vmlinuz $(BOARD).itb \
		--bootloader cmdline

cmdline:
	tee cmdline <<<"console=tty1 verbose root=/dev/sda4 rootwait ro init=/sbin/init"
