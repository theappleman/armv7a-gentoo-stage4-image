ELLA_RO = $(shell find support/root_overlay/ -type f)
OMAHA_RO = $(shell find omaha/root_overlay/ -type f)
export VERSION ?= headless
export ZYNQ ?= 7010
export DTB  ?= zynq-parallella.dtb
export FPGA ?= support/parabuntu/fpga_bitfiles
SSH_KEY ?= support/root_overlay/root/.ssh/authorized_keys
WPA ?= omaha/root_overlay/etc/wpa_supplicant/wpa_supplicant.conf
NECESSARY = \
	$(KDIR)/arch/arm/boot/uImage \
	$(KDIR)/arch/arm/boot/dts/$(DTB) \
	$(FPGA)/parallella_e16_$(VERSION)_gpiose_$(ZYNQ).bit.bin

%.img.bz2: %.img
	bzip2 -kfp $<
	@echo
	touch $@

parallella-$(VERSION)-$(ZYNQ).img: ella-rootfs.tar.bz2 $(NECESSARY) $(ELLA_RO) $(SSH_KEY)
	./.gfwrapper.sh $@ $< support/root_overlay || rm -f $@

omaha.img: chromebook-rootfs.tar.bz2 omaha.kpart /lib/firmware/mrvl/sd8797_uapsta.bin $(NECESSARY) $(OMAHA_RO) $(WPA)
	./.gfomaha.sh $@ $< omaha/root_overlay || rm -f $@

stage3-armv7a_hardfp-latest.tar.bz2:
	export getpath=$$(wget -q -O- https://distfiles.gentoo.org/releases/arm/autobuilds/latest-stage3-armv7a_hardfp-systemd.txt | awk 'NR==3{print$$1}'); \
	wget -c http://distfiles.gentoo.org/releases/arm/autobuilds/$$getpath; \
	ln -s $$(basename $$getpath) $@

$(FPGA)/parallella_e16_microserver_gpiose_$(ZYNQ).bit.bin: $(FPGA)/parallella_e16_headless_gpiose_$(ZYNQ).bit.bin
	cp -v $< $@

kernel.itb: omaha/kernel.its $(KDIR)/arch/arm/boot/zImage $(wildcard $(KDIR)/arch/arm/boot/dts/*.dtb)
	cp -v $< $(KDIR)/kernel.its
	mkimage -f $(KDIR)/kernel.its $@

omaha.kpart: kernel.itb cmdline
	vbutil_kernel \
		--version 1 \
		--pack $@ \
		--arch arm \
		--keyblock /usr/share/vboot/devkeys/kernel.keyblock \
		--signprivate /usr/share/vboot/devkeys/kernel_data_key.vbprivk \
		--config cmdline \
		--vmlinuz $< \
		--bootloader cmdline

cmdline:
	tee $@ <<<"console=tty1 verbose root=/dev/sda4 rootwait ro init=/sbin/init"
