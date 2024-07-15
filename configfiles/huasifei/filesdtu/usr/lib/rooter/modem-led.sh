#!/bin/sh

log() {
	logger -t "modem-led " "$@"
}

CURRMODEM=$1
COMMD=$2

	case $COMMD in
		"0" )
			echo none > /sys/class/leds/green:4g/trigger
			echo 0  > /sys/class/leds/green:4g/brightness
			echo none > /sys/class/leds/green:5g/trigger
			echo 0  > /sys/class/leds/green:5g/brightness
			echo none > /sys/class/leds/green:signal2/trigger
			echo 0  > /sys/class/leds/green:signal2/brightness
			echo none > /sys/class/leds/green:signal3/trigger
			echo 0  > /sys/class/leds/green:signal3/brightness
			;;
		"1" )
			echo timer > /sys/class/leds/green:4g/trigger
			echo 500  > /sys/class/leds/green:4g/delay_on
			echo 500  > /sys/class/leds/green:4g/delay_off
			;;
		"2" )
			echo timer > /sys/class/leds/green:4g/trigger
			echo 200  > /sys/class/leds/green:4g/delay_on
			echo 200  > /sys/class/leds/green:4g/delay_off
			;;
		"3" )
			echo timer > /sys/class/leds/green:4g/trigger
			echo 1000  > /sys/class/leds/green:4g/delay_on
			echo 0  > /sys/class/leds/green:4g/delay_off
			;;
		"4" )
			echo none > /sys/class/leds/green:4g/trigger
			echo 1  > /sys/class/leds/green:4g/brightness
			sig2=$3
			echo timer > /sys/class/leds/green:5g/trigger
			if [ $sig2 -lt 18 -a $sig2 -gt 0 ] 2>/dev/null;then
				echo 500  > /sys/class/leds/green:5g/delay_on
				echo 500  > /sys/class/leds/green:5g/delay_off
				echo none > /sys/class/leds/green:signal2/trigger
				echo 1  > /sys/class/leds/green:signal2/brightness
				echo none > /sys/class/leds/green:signal3/trigger
				echo 0  > /sys/class/leds/green:signal3/brightness
			elif [ $sig2 -ge 18 -a $sig2 -lt 31 ] 2>/dev/null;then
				echo 150  > /sys/class/leds/green:5g/delay_on
				echo 150  > /sys/class/leds/green:5g/delay_off
				echo none > /sys/class/leds/green:signal2/trigger
				echo 1  > /sys/class/leds/green:signal2/brightness
				echo none > /sys/class/leds/green:signal3/trigger
				echo 1  > /sys/class/leds/green:signal3/brightness
			elif [ $sig2 -eq 31 ] 2>/dev/null;then
				echo 0  > /sys/class/leds/green:5g/delay_on
				echo 1000  > /sys/class/leds/green:5g/delay_off
				echo none > /sys/class/leds/green:signal3/trigger
				echo 1  > /sys/class/leds/green:signal3/brightness
				echo none > /sys/class/leds/green:signal2/trigger
				echo 1  > /sys/class/leds/green:signal2/brightness
				echo none > /sys/class/leds/green:signal3/trigger
				echo 1  > /sys/class/leds/green:signal3/brightness
			else
				echo 950  > /sys/class/leds/green:5g/delay_on
				echo 950  > /sys/class/leds/green:5g/delay_off
			fi
			;;
	esac
