#!/usr/bin/env python2

import guestfs

img = "parallella.img"
imgcntnr = "raw"
imgsz = 1280 * 1024 * 1024 #1280MiB
bootsec = 128 * 1000 * 1000 # 128MB

g = guestfs.GuestFS(python_return_dict=True)

g.set_trace(1)

g.disk_create(img, imgcntnr, imgsz)
g.add_drive_opts(img, 0, imgcntnr)
g.launch()

for dev in g.list_devices():
  blockss = g.blockdev_getss(dev)
  g.part_init(dev, "mbr")
  g.part_add(dev, "primary", 1, bootsec)
  g.part_add(dev, "primary", bootsec + 1, -1)
  
  parts = g.list_partitions()
  boot = parts[0]
  root = parts[1]
  
  g.mkfs("vfat", boot)
  g.mkfs("btrfs", root)
  
  g.mount(root, "/")
