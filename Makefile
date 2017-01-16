STAGE4 = $(shell find stage4/ -type f)
VERSION ?= microserver

%.img.bz2: %.img
	bzip2 -kfp $<
	@echo
	touch $@

stage4/boot/%: %
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

parallella.img: stage3-armv7a_hardfp-latest.tar.bz2 stage4/boot/parallella.bit.bin stage4/boot/uImage stage4/boot/devicetree.dtb $(STAGE4)
	./.gfwrapper.sh $@ $< stage4 || rm -f $@

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


rpi6.img: stage3-armv6j_hardfp-latest.tar.bz2 stage4/boot/cmdline.txt stage4/boot/kernel.img stage4/boot/bootcode.bin stage4/boot/fixup.dat stage4/boot/fixup_cd.dat stage4/boot/start.elf stage4/boot/start_cd.elf $(STAGE4)
	./.gfwrapper.sh $@ $< stage4 || rm -f $@

stage3-armv6j_hardfp-latest.tar.bz2:
	export getpath=$$(wget -q -O- http://distfiles.gentoo.org/releases/arm/autobuilds/latest-stage3-armv6j_hardfp.txt | awk 'NR==3{print$$1}'); \
	wget -c http://distfiles.gentoo.org/releases/arm/autobuilds/$$getpath; \
	ln -s $$(basename $$getpath) $@
