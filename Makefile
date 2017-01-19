STAGE4 = $(shell find stage4/ -type f)
VERSION ?= microserver
ZYNQ ?= 7010

%.img.bz2: %.img
	bzip2 -kfp $<
	@echo
	touch $@

stage4/boot/%: %
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

parallella-$(VERSION)-$(ZYNQ).img: stage3-armv7a_hardfp-latest.tar.bz2 stage4/boot/parallella.bit.bin stage4/boot/uImage stage4/boot/devicetree.dtb $(STAGE4)
	./.gfwrapper.sh $@ $< stage4 || rm -f $@

stage4/boot/parallella.bit.bin: parallella_e16_$(VERSION)_gpiose_$(ZYNQ).bit.bin
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

stage4/boot/devicetree.dtb: zynq-parallella-$(VERSION).dtb
	@test -d stage4/boot || mkdir -p stage4/boot
	cp $< $@

parallella_e16_microserver_gpiose_70%0.bit.bin: parallella_e16_headless_gpiose_70%0.bit.bin
	cp $< $@

zynq-parallella-hdmi.dtb: zynq-parallella.dtb
	cp $< $@

stage3-armv7a_hardfp-latest.tar.bz2:
	export getpath=$$(wget -q -O- http://distfiles.gentoo.org/releases/arm/autobuilds/latest-stage3-armv7a_hardfp.txt | awk 'NR==3{print$$1}'); \
	wget -c http://distfiles.gentoo.org/releases/arm/autobuilds/$$getpath; \
	ln -s $$(basename $$getpath) $@

.PHONY: clean
clean:
	rm -vfr stage4/boot
	rm -vfr stage4/lib
