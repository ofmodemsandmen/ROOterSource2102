#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "USB " "$@"
}

uci set usb.usb.usb=$1
uci commit usb
echo "$1" > /sys/class/gpio/ext-usb/value