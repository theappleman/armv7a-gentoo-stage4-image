STAGE4 = $(shell find stage4/ -type f)

parallella.img.bz2: parallella.img
	bzip2 -kfp $<
	@echo
	touch $@

parallella.img: stage3-armv7a_hardfp-latest.tar.bz2 stage4/boot/parallella.bit.bin stage4/boot/uImage stage4/boot/devicetree.dtb $(STAGE4)
	./.gfwrapper.sh $@ $< stage4 || rm -f $@

stage4/boot/parallella.bit.bin: parallella_e16_headless_gpiose_7010.bit.bin
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage4/boot/uImage: uImage
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage4/boot/devicetree.dtb: zynq-parallella-headless.dtb
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage3-armv7a_hardfp-latest.tar.bz2:
	@echo Download the tarball from the following url and name it $@:
	@echo http://distfiles.gentoo.org/releases/arm/autobuilds/current-stage3-armv7a_hardfp/
	@exit 1
