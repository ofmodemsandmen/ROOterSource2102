#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	modlog "Celldata" "$@"
}

CURRMODEM=$1
COMMPORT=$2
idV=$(uci -q get modem.modem$CURRMODEM.idV)
idP=$(uci -q get modem.modem$CURRMODEM.idP)
cps="+COPS: "

if [ -e /etc/nocops ]; then
	echo "0" > /tmp/block
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "cellinfo0.gcom" "$CURRMODEM")
	rm -f /tmp/block
else
	OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "cellinfo0.gcom" "$CURRMODEM")
fi
OY=$($ROOTER/gcom/gcom-locked "$COMMPORT" "cellinfo.gcom" "$CURRMODEM")
OXx=$OX

OX=$(echo $OX | tr 'a-z' 'A-Z')
OY=$(echo $OY | tr 'a-z' 'A-Z')
OX=$OX" "$OY
COPS="-"
COPS_MCC="-"
COPS_MNC="-"
COPSX=$(echo $OXx | grep -o "$cps""[01],0,.\+," | cut -d, -f3 | grep -o "[^\"]\+")
if [ -z "$COPSX" ]; then
	cps="+COPS:"
	COPSX=$(echo $OXx | grep -o "$cps""[01],0,.\+," | cut -d, -f3 | grep -o "[^\"]\+")
fi
if [ "x$COPSX" != "x" ]; then
	COPS=$COPSX
fi

if [ "$COPS" = " " ]; then
	COPSY=$(echo $OXx | grep -o "AT+COPS=0,0;+COPS? $cps""[01],0,.\+," | cut -d, -f4 | grep -o "[^\"]\+")
	COPS="-"
	if [ "x$COPSY" != "x" ]; then
		COPS=$COPSY
	fi
fi

COPSX=$(echo $OX | grep -o "$cps""[01],2,.\+," | cut -d, -f3 | grep -o "[^\"]\+")

if [ "x$COPSX" != "x" ]; then
	COPS_MCC=${COPSX:0:3}
	COPS_MNC=${COPSX:3:3}
	fmc=${COPS_MNC:0:1}
	COPS_MNC1=$COPS_MNC
	if [ "$fmc" = "0" ]; then
		COPS_MNC1=${COPSX:4:2}
	fi
	if [ "$COPS" = " " ]; then
		mccdata="/usr/lib/country/mccdata"
		if [ -e "$mccdata" ]; then
			nn=""
			while IFS= read -r line; do
				if [ -z "$nn" ]; then
					nn=$line
					read -r line
				fi
				country=$(echo "$line" | cut -d\| -f1)
				mcc=$(echo "$country" | cut -d, -f2)
				if [ "$mcc" = "$COPS_MCC" ]; then
					st=2
					nm=""
					while [ 1 = 1 ]; do
						isp=$(echo "$line" | cut -d\| -f$st)
						if [ -z "$isp" ]; then
							break
						fi
						mnc=$(echo "$isp" | cut -d, -f1)
						if [ "$mnc" = "$COPS_MNC1" ]; then
							if [ -z "$nm" ]; then
								nm=$(echo "$isp" | cut -d, -f3)
							else
								nm=$nm" | "$(echo "$isp" | cut -d, -f3)
							fi
						fi
						let st=$st+1
					done
					COPS="$nm"
				fi
			done < $mccdata
		fi
	fi
	if [ "$COPS" = "-" ]; then
		COPS=$(awk -F[\;] '/'$COPS'/ {print $2}' $ROOTER/signal/mccmnc.data)
		[ "x$COPS" = "x" ] && COPS="-"
	fi
fi

if [ "$COPS" = "-" ]; then
	COPS=$(echo "$OX" | awk -F[\"] "/^\$cps"'0,0/ {print $1}')
	if [ "x$COPS" = "x" ]; then
		COPS="-"
		COPS_MCC="-"
		COPS_MNC="-"
	fi
fi
COPS_MNC=" "$COPS_MNC

OX=$(echo "${OX//[ \"]/}")

CID=""
CID5=""
RAT=""
REGSTAT=""
REGV=$(echo "$OX" | grep -o "+C5GREG:2,[0-9],[A-F0-9]\{2,6\},[A-F0-9]\{5,10\},[0-9]\{1,2\}")
if [ -n "$REGV" ]; then
	REGSTAT=$(echo "$REGV" | cut -d, -f2)
	LAC5=$(echo "$REGV" | cut -d, -f3)
	LAC5=$LAC5" ($(printf "%d" 0x$LAC5))"
	CID5=$(echo "$REGV" | cut -d, -f4)
	CID5L=$(printf "%010X" 0x$CID5)
	RNC5=${CID5L:1:6}
	RNC5=$RNC5" ($(printf "%d" 0x$RNC5))"
	CID5=${CID5L:7:3}
	CID5="Short $(printf "%X" 0x$CID5) ($(printf "%d" 0x$CID5)), Long $(printf "%X" 0x$CID5L) ($(printf "%d" 0x$CID5L))"
	RAT=$(echo "$REGV" | cut -d, -f5)
fi
REGV=$(echo "$OX" | grep -o "+CEREG:2,[0-9],[A-F0-9]\{2,4\},[A-F0-9]\{5,8\}")
REGFMT="3GPP"
if [ -z "$REGV" ]; then
	REGV=$(echo "$OX" | grep -o "+CEREG:2,[0-9],[A-F0-9]\{2,4\},[A-F0-9]\{1,3\},[A-F0-9]\{5,8\}")
	REGFMT="SW"
fi
if [ -n "$REGV" ]; then
	LAC=$(echo "$REGV" | cut -d, -f3)
	LAC=$(printf "%04X" 0x$LAC)" ($(printf "%d" 0x$LAC))"
	if [ $REGFMT = "3GPP" ]; then
		CID=$(echo "$REGV" | cut -d, -f4)
	else
		CID=$(echo "$REGV" | cut -d, -f5)
	fi
	CIDL=$(printf "%08X" 0x$CID)
	RNC=${CIDL:1:5}
	RNC=$RNC" ($(printf "%d" 0x$RNC))"
	CID=${CIDL:6:2}
	CID="Short $(printf "%X" 0x$CID) ($(printf "%d" 0x$CID)), Long $(printf "%X" 0x$CIDL) ($(printf "%d" 0x$CIDL))"

else
	REGV=$(echo "$OX" | grep -o "+CREG:2,[0-9],[A-F0-9]\{2,4\},[A-F0-9]\{2,8\}")
	if [ -n "$REGV" ]; then
		LAC=$(echo "$REGV" | cut -d, -f3)
		CID=$(echo "$REGV" | cut -d, -f4)
		if [ ${#CID} -gt 4 ]; then
			LAC=$(printf "%04X" 0x$LAC)" ($(printf "%d" 0x$LAC))"
			CIDL=$(printf "%08X" 0x$CID)
			RNC=${CIDL:1:3}
			CID=${CIDL:4:4}
			CID="Short $(printf "%X" 0x$CID) ($(printf "%d" 0x$CID)), Long $(printf "%X" 0x$CIDL) ($(printf "%d" 0x$CIDL))"
		else
			LAC=""
		fi
	else
		LAC=""
	fi
fi
if [ -z "$REGSTAT" ]; then
	REGSTAT=$(echo "$REGV" | cut -d, -f2)
fi
if [ "$REGSTAT" == "5" -a "$COPS" != "-" ]; then
	COPS_MNC=$COPS_MNC" (Roaming)"
fi
if [ -n "$CID" -a -n "$CID5" ] && [ "$RAT" == "13" -o "$RAT" == "10" ]; then
	LAC="4G $LAC, 5G $LAC5"
	CID="4G $CID<br />5G $CID5"
	RNC="4G $RNC, 5G $RNC5"
elif [ -n "$CID5" ]; then
	LAC=$LAC5
	CID=$CID5
	RNC=$RNC5
fi
if [ -z "$LAC" ]; then
	LAC="-"
	CID="-"
	RNC="-"
fi

{
	echo 'COPS="'"$COPS"'"'
	echo 'COPS_MCC="'"$COPS_MCC"'"'
	echo 'COPS_MNC="'"$COPS_MNC"'"'
	echo 'LAC="'"$LAC"'"'
	echo 'LAC_NUM="'""'"'
	echo 'CID="'"$CID"'"'
	echo 'CID_NUM="'""'"'
	echo 'RNC="'"$RNC"'"'
	echo 'RNC_NUM="'""'"'
} > /tmp/cell$CURRMODEM.file
