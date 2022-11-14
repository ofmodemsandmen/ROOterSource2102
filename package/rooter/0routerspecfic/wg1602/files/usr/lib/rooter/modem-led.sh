#!/bin/sh

log() {
	modlog "modem-led " "$@"
}

CURRMODEM=$1
COMMD=$2

DEV=$(uci get modem.modem$CURRMODEM.device)
log "$COMMD $DEV"
if [ $DEV = "1-2" ]; then
	case $COMMD in
		"0" )
			echo timer > /sys/class/leds/green:4g1/trigger
			echo 0  > /sys/class/leds/green:4g1/delay_on
			echo 1000  > /sys/class/leds/green:4g1/delay_off
			;;
		"1" )
			echo timer > /sys/class/leds/green:4g1/trigger
			echo 500  > /sys/class/leds/green:4g1/delay_on
			echo 500  > /sys/class/leds/green:4g1/delay_off
			;;
		"2" )
			echo timer > /sys/class/leds/green:4g1/trigger
			echo 200  > /sys/class/leds/green:4g1/delay_on
			echo 200  > /sys/class/leds/green:4g1/delay_off
			;;
		"3" )
			echo timer > /sys/class/leds/green:4g1/trigger
			echo 1000  > /sys/class/leds/green:4g1/delay_on
			echo 0  > /sys/class/leds/green:4g1/delay_off
			;;
		"4" )
			echo none > /sys/class/leds/green:4g1/trigger
			echo 1  > /sys/class/leds/green:4g1/brightness
			;;
			;;
	esac
else
	case $COMMD in
		"0" )
			echo timer > /sys/class/leds/green:4g2/trigger
			echo 0  > /sys/class/leds/green:4g2/delay_on
			echo 1000  > /sys/class/leds/green:4g2/delay_off
			;;
		"1" )
			echo timer > /sys/class/leds/green:4g2/trigger
			echo 500  > /sys/class/leds/green:4g2/delay_on
			echo 500  > /sys/class/leds/green:4g2/delay_off
			;;
		"2" )
			echo timer > /sys/class/leds/green:4g2/trigger
			echo 200  > /sys/class/leds/green:4g2/delay_on
			echo 200  > /sys/class/leds/green:4g2/delay_off
			;;
		"3" )
			echo timer > /sys/class/leds/green:4g2/trigger
			echo 1000  > /sys/class/leds/green:4g2/delay_on
			echo 0  > /sys/class/leds/green:4g2/delay_off
			;;
		"4" )
			echo none > /sys/class/leds/green:4g2/trigger
			echo 1  > /sys/class/leds/green:4g2/brightness
			;;
	esac

fi