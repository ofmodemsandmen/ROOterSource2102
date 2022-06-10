#!/bin/sh

RADIO=$(uci get wireless.wwan.device)
ap_list="$(ubus -S call network.wireless status | jsonfilter -e "@.$RADIO.interfaces[@.config.mode=\"ap\"].ifname")"
if [ -z $ap_list ]; then
	wifi up
	ap_list="$(ubus -S call network.wireless status | jsonfilter -e "@.$RADIO.interfaces[@.config.mode=\"ap\"].ifname")"
fi

rm -f /tmp/ssidlist
for ap in ${ap_list}
do
	iwinfo "${ap}" scan >> /tmp/ssidlist
done
