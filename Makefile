STAGE4 = $(shell find stage4/ -type f)
export VERSION ?= headless
export ZYNQ ?= 7010
export KDIR ?= support/linux
export DTB  ?= zynq-parallella.dtb
export FPGA ?= support/parabuntu/fpga_bitfiles
NECESSARY = \
	$(KDIR)/arch/arm/boot/uImage \
	$(KDIR)/arch/arm/boot/dts/$(DTB) \
	$(FPGA)/parallella_e16_$(VERSION)_gpiose_$(ZYNQ).bit.bin

%.img.bz2: %.img
	bzip2 -kfp $<
	@echo
	touch $@

parallella-$(VERSION)-$(ZYNQ).img: stage3-armv7a_hardfp-latest.tar.bz2 $(NECESSARY) $(STAGE4)
	./.gfwrapper.sh $@ $< stage4 || rm -f $@

stage3-armv7a_hardfp-latest.tar.bz2:
	export getpath=$$(wget -q -O- https://distfiles.gentoo.org/releases/arm/autobuilds/latest-stage3-armv7a_hardfp-systemd.txt | awk 'NR==3{print$$1}'); \
	wget -c http://distfiles.gentoo.org/releases/arm/autobuilds/$$getpath; \
	ln -s $$(basename $$getpath) $@

.PHONY: clean
clean:
	rm -vfr stage4/boot
	rm -vfr stage4/lib
