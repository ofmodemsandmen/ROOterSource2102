#!/bin/sh

#for example WE825-Q watchdog gpio is 2
# WE826 is 11
wd_gpio="491"

echo $wd_gpio > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$wd_gpio/direction
echo 494 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio494/direction
echo 255 >/sys/class/gpio/gpio494/value

while [ 1 ]
do
    echo 255 >/sys/class/gpio/gpio$wd_gpio/value
    sleep 1
    echo 0 >/sys/class/gpio/gpio$wd_gpio/value
    sleep 1
done
