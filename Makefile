STAGE4 = $(shell find stage4/ -type f)
VERSION ?= headless

parallella.img.bz2: parallella.img
	bzip2 -kfp $<
	@echo
	touch $@

parallella.img: stage3-armv7a_hardfp-latest.tar.bz2 stage4/boot/parallella.bit.bin stage4/boot/uImage stage4/boot/devicetree.dtb $(STAGE4)
	./.gfwrapper.sh $@ $< stage4 || rm -f $@

stage4/boot/parallella.bit.bin: parallella_e16_$(VERSION)_gpiose_7010.bit.bin
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage4/boot/uImage: uImage
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage4/boot/devicetree.dtb: zynq-parallella-$(VERSION).dtb
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage3-armv7a_hardfp-latest.tar.bz2:
	export getpath=$$(wget -q -O- http://distfiles.gentoo.org/releases/arm/autobuilds/latest-stage3-armv7a_hardfp.txt | awk 'NR==3{print$$1}'); \
	wget -c http://distfiles.gentoo.org/releases/arm/autobuilds/$$getpath; \
	ln -s $$(basename $$getpath) $@
