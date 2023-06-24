#!/bin/sh

flg=$1

us=$(uci -q get nlbwmon.nlbwmon.enabled)
if [ "$flg" = "$us" ]; then
	exit 0
fi
uci set nlbwmon.nlbwmon.enabled=$flg
uci commit nlbwmon

if [ "$flg" = "0" ]; then
	cp /usr/lib/bwmon/luci-app-nlbwmonoff.json /usr/share/luci/menu.d/luci-app-nlbwmon.json
	/etc/init.d/nlbwmon stop &
else
	cp /usr/lib/bwmon/luci-app-nlbwmonon.json /usr/share/luci/menu.d/luci-app-nlbwmon.json
	/etc/init.d/nlbwmon start &
fi