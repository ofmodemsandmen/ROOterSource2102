#!/bin/sh

cmd=$1

if [ "$cmd" = "usb" ]; then
	cmdline='console=serial0,115200 console=tty1 root=/dev/sda2 rootfstype=squashfs,ext4 rootwait'
	echo "$cmdline" > ./target/linux/bcm27xx/image/cmdline.txt
else
	if [ "$cmd" = "sd" ]; then
		cmdline='console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=squashfs,ext4 rootwait'
		echo "$cmdline" > ./target/linux/bcm27xx/image/cmdline.txt
	fi
fi

