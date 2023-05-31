#!/bin/sh

flag=$1

if [ "$flag" = "old" ]; then
	mv ./package/network/utils/iwinfo/Makefile ./package/network/utils/iwinfo/Makefile-new
	mv ./package/network/utils/iwinfo/Makefile-old ./package/network/utils/iwinfo/Makefile
	mv ./package/network/utils/iwinfo/patches-old ./package/network/utils/iwinfo/patches
else
	mv ./package/network/utils/iwinfo/Makefile ./package/network/utils/iwinfo/Makefile-old
	mv ./package/network/utils/iwinfo/Makefile-new ./package/network/utils/iwinfo/Makefile
	mv ./package/network/utils/iwinfo/patches ./package/network/utils/iwinfo/patches-old
fi