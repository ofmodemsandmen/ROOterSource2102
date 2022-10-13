#!/bin/sh

OX16='#start1602
define Device/zbtlink_zbt-wg1602-16m
  $(Device/dsa-migration)
  $(Device/uimage-lzma-loader)
  IMAGE_SIZE := 16064k
  DEVICE_VENDOR := Zbtlink
  DEVICE_MODEL := ZBT-WG1602
  DEVICE_VARIANT := 16M
  DEVICE_PACKAGES := kmod-sdhci-mt7620 kmod-mt7603 kmod-mt76x2 kmod-usb3 \
	kmod-usb-ledtrig-usbport
endef
TARGET_DEVICES += zbtlink_zbt-wg1602-16m
#end1602'

OX32='#start1602
define Device/zbtlink_zbt-wg1602-16m
  $(Device/dsa-migration)
  $(Device/uimage-lzma-loader)
  IMAGE_SIZE := 32448k
  DEVICE_VENDOR := Zbtlink
  DEVICE_MODEL := ZBT-WG1602
  DEVICE_VARIANT := 32M
  DEVICE_PACKAGES := kmod-sdhci-mt7620 kmod-mt7603 kmod-mt76x2 kmod-usb3 \
	kmod-usb-ledtrig-usbport
endef
TARGET_DEVICES += zbtlink_zbt-wg1602-16m
#end1602'

cmd=$1

dts="/image/mt7621.mk"
cp -f ./$dts ./$dts".bk"
sed /"#start1602"/,/"#end1602"/d ./$dts".bk" > ./$dts
if [ "$cmd" = "16" ]; then
	echo "$OX16" >> ./$dts
else
	if [ "$cmd" = "32" ]; then
		echo "$OX32" >> ./$dts
	fi
fi 
rm -f ./$dts".bk"

dts="./dts/mt7621_zbtlink_zbt-wg1602-16m.dts"
if [ "$cmd" = "16" ]; then
	sed -i -e "s!reg = <0x50000 0x1fb0000>;!reg = <0x50000 0xfb0000>;!g" $dts
else
	if [ "$cmd" = "32" ]; then
		sed -i -e "s!reg = <0x50000 0xfb0000>;!reg = <0x50000 0x1fb0000>;!g" $dts
	fi
fi 

