#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	modlog "Fibocom Data" "$@"
}

CURRMODEM=$1
COMMPORT=$2
idP=$(uci get modem.modem$CURRMODEM.idP)

decode_signal() {
	if [ "$CRAT" -eq 4 ]; then
		RSCPs=$(($RSRP - 141))
		if [ -n "$RSCP" ]; then
			RSCP=$RSCP","$RSCPs
		else
			RSCP=$RSCPs
		fi
		if [ -n "$ECIO" ]; then
			ECIO=$ECIO","$((($RSRQ / 2) - 20))
		else
			ECIO=$((($RSRQ / 2) - 20))
		fi
	elif [ "$CRAT" -eq 9 ]; then
		RSCPs=$(($RSRP - 157))
		if [ -n "$RSCP" ]; then
			RSCP=$RSCP","$RSCPs
		else
			RSCP=$RSCPs
		fi
		if [ -n "$ECIO" ]; then
			ECIO=$ECIO","$((($RSRQ / 2) - 43))
		else
			ECIO=$((($RSRQ / 2) - 43))
		fi
	fi
}
decode_bw() {
	case $BW in
		"0")
			BW="1.4" ;;
		"1")
			BW="3" ;;
		"2")
			BW="5" ;;
		"3")
			BW="10" ;;
		"4")
			BW="15" ;;
		"5")
			BW="20" ;;
		*)
			BW="-";;
	esac
}

OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "fibocominfo.gcom" "$CURRMODEM")

OX=$(echo $OX | tr 'a-z' 'A-Z')
echo "$OX" > /tmp/sccone1
sed -i 's/SCC 1/SCC1/g' /tmp/sccone1
OX=$(cat /tmp/sccone1)
rm -f /tmp/sccone
SERVING=$(echo $OX | grep -o "+GTCCINFO:.\+GTRAT")
echo "$SERVING" > /tmp/sccone
sed -i 's/,,,/,1,1,/g' /tmp/sccone
SERVING=$(cat /tmp/sccone)

REGXa="[12],[249],[0-9]\{3\},[0-9]\{1,3\},[0-9A-F]\{0,6\},[0-9A-F]\{0,10\},[0-9A-F]\{1,8\},[0-9A-F]\{1,8\},[15][0-9]\{0,4\},[0-9]\{0,4\},[-0-9]\{0,5\},[0-9]\{0,3\},[0-9]\{0,3\},[0-9]\{0,3\}"
REGXb="+GTCAINFO: 1,[0-9]\{1,2\},[0-9]\{3\},[0-9]\{2,3\},[0-9]\{1,5\},[0-9]\{3,9\},[0-9]\{1,3\},[0-9]\{1,3\},[0-9]\{1,3\},[-0-9]\{1,4\},[0-9]\{1,6\},[0-9]\{1,6\},[0-9]\{1,3\},[0-9]\{1,3\}"
REGXc="+GTCAINFO: [2-9],[0-9]\{1,2\},[0-9]\{1,5\},[0-9]\{1,3\},[0-9]\{1,3\},[-0-9]\{1,4\},[0-9]\{1,5\},[0-9]\{1,5\},[0-9]\{1,3\},[0-9]\{1,3\}"
REGXd="+XMCI: 2,[0-9]\{3\},[0-9]\{2,3\},[^,]\+,[^,]\+,[^,]\+,\"0X[0-9A-F]\{8\}\",[^,]\+,[^,]\+,[0-9]\{1,2\},[0-9]\{1,2\},[0-9]\{1,2\}"
REGXe="+XMCI: 4,[0-9]\{3\},[0-9]\{2,3\},[^,]\+,[^,]\+,\"0X[0-9A-F]\{4\}\",\"0X[0-9A-F]\{8\}\",[^,]\+,[^,]\+,[0-9]\{1,2\},[0-9]\{1,2\},[-0-9]\{1,5\}"
REGXh="2,9,,,,,[0-9A-F]\{5\},[0-9A-F]\{1,3\},,[0-9]\{1,3\},[0-9]\{1,3\},[0-9]\{1,3\}"
REGXj="+GTCAINFO:.\+SCC1[^O]\+"
REGXy="1,9,[0-9]\{0,3\},[0-9]\{0,3\},[0-9A-F]\{0,7\},[0-9A-F]\{0,10\},[0-9A-F]\{1,8\},[0-9A-F]\{1,8\},[15][0-9]\{1,4\},[0-9]\{1,4\},[-0-9]\{1,5\},[0-9]\{1,3\},[0-9]\{1,3\},[0-9]\{1,3\}"

if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
	REGXg="2,4,[0-9]\{0,3\},[0-9]\{0,3\},[0-9A-F]\{0,7\},[0-9A-F]\{0,10\},[0-9A-F]\{1,8\},[0-9A-F]\{0,8\},[0-9]\{0,4\},[0-9]\{0,3\},[-0-9]\{0,5\},[0-9]\{0,3\}"
	REGXf="SCC[0-9]:[1,2,3\],0,[0-9]\{1,3\},[0-9]\{2,3\},[0-9]\{1,6\},[0-9]\{1,3\}"
else
	REGXg="2,4,,,,,[0-9A-F]\{1,7\},[0-9A-F]\{1,3\},,[0-9]\{1,3\},[0-9]\{1,3\},[0-9]\{1,3\}"
	REGXf="SCC[0-9]: 1,0,[0-9]\{1,3\},1[0-9]\{2\},[0-9]\{1,6\},[0-9]\{1,3\}"
fi

CHANNEL="-"
ECIO="-"
RSCP="-"
ECIO1=" "
RSCP1=" "
MODE="-"
NETMODE="-"
LBAND="-"
PCI="-"
CTEMP="-"
SINR=""
COPS_MCC=""
RSRPCA=""
PCICA=""
CHANCA=""

CSQ=$(echo $OX | grep -o "+CSQ: [0-9]\{1,2\}" | grep -o "[0-9]\{1,2\}")
if [ "$CSQ" = "99" ]; then
	CSQ=""
fi
if [ -n "$CSQ" ]; then
	CSQ_PER=$(($CSQ * 100/31))"%"
	CSQ_RSSI=$((2 * CSQ - 113))" dBm"
else
	CSQ="-"
	CSQ_PER="-"
	CSQ_RSSI="-"
fi

if [ -n "$SERVING" ]; then
	if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
		MODE=$SERVING
		MODE=$(echo "$MODE" | tr " " ",")
		NSA=$(echo "$MODE" | cut -d, -f16)
		if [ "$NSA" != "1" ]; then
			NSA="0"
		fi
		GTCCDATAy=""
		MODEX=$MODE
		MODE=$(echo "$MODE" | cut -d, -f3)
		case $MODE in
		"2" )
			MODE="WCDMA"
			;;
		"4" )
			MODE="LTE"
			if [ "$NSA" = "1" ]; then
				FG=$(echo "$MODEX" | cut -d, -f17)
				if [ "$FG" = "9" ]; then
					MODE="5G NSA"
					GTCCDATAy=$(echo $SERVING | grep -o "$REGXy")
				fi
			fi
			;;
		"9" )
			MODE="5G SA"
			;;
		esac
	else
		MODE=$(echo $SERVING | grep -o "+GTCCINFO: .\+ SERVICE CELL:")
		LENM=${#MODE}
		if [ $LENM -gt 25 ]; then
			MODE=${MODE:11:$LENM-25}
		else
			MODE="-"
		fi
	fi
	GTCCDATA=$(echo $SERVING | grep -o "$REGXa")
	LTENEIGH=$(echo $SERVING | grep -o "$REGXg")
	NRNEIGH=$(echo $SERVING | grep -o "$REGXh")
	echo "" > /tmp/scan$CURRMODEM

	for NVAL in $(echo "$LTENEIGH"); do
		CHAN=$(echo $NVAL | cut -d, -f7)
		if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
			CHAN=$CHAN
		else
			CHAN=$(printf "%d" 0x$CHAN)
		fi
		BAND=$(/usr/lib/rooter/chan2band.sh $CHAN)
		PCIx=$(echo $NVAL | cut -d, -f8)
		PCIx=$(printf "%d" 0x$PCIx)
		RSSI=$(echo $NVAL | cut -d, -f11)
		RSSI=$(($RSSI - 141))
		echo -e "Band : $BAND\tPCI : $PCIx\tSignal : $RSSI (dBm)" >> /tmp/scan$CURRMODEM
	done
	for NVAL in $(echo "$NRNEIGH"); do
		CHAN=$(echo $NVAL | cut -d, -f7)
		CHAN=$(printf "%d" 0x$CHAN)
		BAND=$(/usr/lib/rooter/chan2band.sh $CHAN)
		PCIx=$(echo $NVAL | cut -d, -f8)
		PCIx=$(printf "%d" 0x$PCIx)
		RSSI=$(echo $NVAL | cut -d, -f11)
		RSSI=$(($RSSI - 157))
		echo -e "Band : $BAND\tPCI : $PCIx\tSignal : $RSSI (dBm)" >> /tmp/scan$CURRMODEM
	done
	CADATA1=""
	CADATA2=""
	XUDATA=""
	XLDATA=""
else
	GTCCDATA=""
	CADATA1=$(echo $OX | grep -o "$REGXb")
	CADATA2=$(echo $OX | grep -o "$REGXc")
	if [ -n "$CADATA2" ]; then
		if [ "$(echo $CADATA2 | cut -d, -f7)" = "65535" ]; then
			CADATA2=""
		fi
	fi
	XUDATA=$(echo $OX | grep -o "$REGXd")
	XLDATA=$(echo $OX | grep -o "$REGXe")
fi

CADATA3=$(echo $OX | grep -o "$REGXf")
CADATA4=$(echo $OX | grep -o "$REGXj" | tr -d " " | tr ":" ",")
if [ -n "$GTCCDATA" ]; then
	COPS_MCC=$(echo $GTCCDATA | cut -d, -f3)
	COPS_MNC=$(echo $GTCCDATA | cut -d, -f4)
	msize=${#COPS_MNC}
	if [ "$msize" -eq 1 ]; then
		COPS_MNC="00"$COPS_MNC
	fi
	if [ "$msize" -eq 2 ]; then
		COPS_MNC="0"$COPS_MNC
	fi
	COPX=""
	if [ -e /tmp/copn.at ]; then
		COPN=$(cat /tmp/copn.at)
	else
		ATCMDD="AT+COPN"
		OXc=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		COPN=$OXc
		if [ ${#COPN} -gt 50 ]; then
			echo $COPN > /tmp/copn.at
		fi
	fi
	COPN=$(echo $COPN | tr " " "," | tr -d '"' )
	if [ -n "$COPN" ]; then
		COPP=$(echo $COPN" " | sed "s/.*\($COPS_MCC$COPS_MNC,,*\)\,/\1/")
		if [ -n "$COPP" ]; then
			COPX=$(echo $COPP | cut -d, -f2)
			if [ "$COPX" = "+COPN:" ]; then
				COPX=""
			fi
		fi
	fi

	LBAND=""
	CHANNEL=""
	RSCP=""
	ECIO=""
	PCI=""
	XUDATA=""
	for CCVAL in $(echo "$GTCCDATA $GTCCDATAy"); do
		CELLTYPE=$(echo $CCVAL | cut -d, -f1)
		CRAT=$(echo $CCVAL | cut -d, -f2)
		BAND=$(echo $CCVAL | cut -d, -f9)
		CHAN=$(echo $CCVAL | cut -d, -f7)
		PCID=$(echo $CCVAL | cut -d, -f8)
		if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
			CHAN=$CHAN
		else
			CHAN=$(printf "%d" 0x$CHAN)
			PCID=$(printf "%d" 0x$PCID)
		fi
		BW=$(echo $CCVAL | cut -d, -f10)
		if [ "$CRAT" -eq 4 ]; then
			SSINR=$(echo $CCVAL | cut -d, -f11 | grep -o "[-0-9]\{1,4\}")
			if [ -n "$SSINR" ] && [ "$SSINR" != "255" ]; then
				SSINR=$(($SSINR / 2))" dB"
			else
				SSINR="-"
			fi
			if [ -n "$SINR" ]; then
				SINR=$SINR"<br />"$SSINR
			else
				SINR=$SSINR
			fi
			if [ $BW -gt 14 ]; then
				BW=$(($(echo $BW) / 5))
			else
				BW="1.4"
			fi
			BAND=${BAND:1}
			if [ "$CELLTYPE" -eq 1 ]; then
				if [ -z "$BAND" ]; then
					BAND=B$(/usr/lib/rooter/chan2band.sh $CHAN)" (Not Showing)"
				else
					BAND="B"$(echo $BAND | sed 's/^0*//')" (Bandwidth: "$BW" MHz)"
				fi
			else
				BAND="B"$(echo $BAND | sed 's/^0*//')" (CA, Bandwidth: "$BW" MHz)"
			fi
		fi
		if [ "$CRAT" -eq 9 ]; then
			SSINR=$(echo $CCVAL | cut -d, -f11 | grep -o "[0-9]\{1,3\}")
			if [ -n "$SSINR" ] && [ "$SSINR" != "255" ]; then
				SSINR=$((($SSINR - 47) / 2))" dB"
			else
				SSINR="-"
			fi
			if [ -n "$SINR" ]; then
				SINR=$SINR"<br />"$SSINR
			else
				SINR=$SSINR
			fi
			size=${#BW}
			size=$size-1
			BW=${BW:0:$size}
			let BW=$BW*2
			if [ "$CELLTYPE" -eq 1 ]; then
				BAND="n"${BAND:2}" (Bandwidth: "$BW" MHz)"
			else
				BAND="n"${BAND:2}" (CA, Bandwidth: "$BW" MHz)"
			fi
		fi
		if [ -n "$LBAND" ]; then
			LBAND=$LBAND"<br />"$BAND
		else
			LBAND=$BAND
		fi
		if [ -n "$CHANNEL" ]; then
			CHANNEL=$CHANNEL","$CHAN
		else
			CHANNEL=$CHAN
		fi
		if [ -n "$PCI" ]; then
			PCI=$PCI","$PCID
		else
			PCI=$PCID
		fi

		OXX=$OX"+ERSRQ"
		if [ "$CELLTYPE" -eq 1 ]; then
			if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
				RSRPP=$(echo $OX | grep -o "+RSRP:.\+RSRQ")
				RSRPP=$(echo $RSRPP | tr " " ",")
				if [ "$CRAT" -eq 4 ]; then
					RSRP=$(echo "$RSRPP" | cut -d, -f6)
				else
					RSRP=$(echo "$RSRPP" | cut -d, -f12)
				fi
				if [ -z "$RSRP" ]; then
					RS=$(echo $CCVAL | cut -d, -f14)
					if [ "$CRAT" -eq 4 ]; then
						let RS=$RS-140
					else
						let RS=$RS-156
					fi
					RSRP=$RS
				fi
				if [ -z "$RSCP" ]; then
					RSCP=$(echo $RSRP | tr -d ' ') 
				else
					RSCP=$RSCP" (4G) dBm<br />"$(echo $RSRP | tr -d ' ')" (5G) " 
				fi

				RSRQQ=$(echo $OXX | grep -o "+RSRQ:.\+ERSRQ")
				RSRQQ=$(echo $RSRQQ | tr " " ",")
				RSRQ=$(echo "$RSRQQ" | cut -d, -f6)
				if [ -z "$RSRQ" ]; then
					RSRQ=$(echo $CCVAL | cut -d, -f13)
					if [ "$CRAT" -eq 4 ]; then
						let RSRQ=$RSRQ-20
					else
						let RSRQ=$RSRQ-43
					fi
				fi
				RSRQ1=$(echo "$RSRQQ" | cut -d, -f12)
				if [ -z "$RSRQ1" ]; then
					RSRQ1=$(echo $CCVAL | cut -d, -f13)
					if [ "$CRAT" -eq 4 ]; then
						let RSRQ1=$RSRQ1-20
					else
						let RSRQ1=$RSRQ1-43
					fi
				fi
				if [ -z "$ECIO" ]; then
					ECIO=$(echo $RSRQ | tr -d ' ')
				else
					ECIO=$ECIO" (4G) dB<br />"$(echo $RSRQ1 | tr -d ' ')" (5G) "
				fi
				if [ "$CRAT" -eq 4 ]; then
					RSSI=$(rsrp2rssi $RSCP $BW)
					CSQ_PER=$((100 - (($RSSI + 51) * 100/-62)))"%"
					CSQ=$((($RSSI + 113) / 2))
					CSQ_RSSI=$RSSI" dBm"
				fi
			else
				RSRP=$(echo $CCVAL | cut -d, -f13)
				RSRQ=$(echo $CCVAL | cut -d, -f14)
				if [ "$RSRP" -ne 255 ] && [ "$RSRQ" -ne 255 ]; then
					decode_signal
					RSSI=$(rsrp2rssi $RSCPs $BW)
					CSQ_PER=$((100 - (($RSSI + 51) * 100/-62)))"%"
					CSQ=$((($RSSI + 113) / 2))
					CSQ_RSSI=$RSSI" dBm"
				fi
			fi
		fi
	done
fi

if [ -n "$XLDATA" ]; then
	XLDATA=$(echo "${XLDATA//[\" ]/}")
	XLEC=$(echo $OX | grep -o "+XLEC: [01],[0-9]\+,[0-5],.*BAND_LTE_[0-9]\{1,2\},[^ ]\+")
	ATRSRP=$(echo $OX | grep -o "+RSRP:[^O]\+")
	ATRSRP=$(echo "$ATRSRP" | grep -o "[0-9]\{1,3\},[0-9]\{1,5\},-[0-9]\{2,3\}")
	MODE="LTE"
	PCI=$(echo $XLDATA | cut -d, -f6)
	PCI=$(printf "%d" $PCI)
	CHANNEL=$(echo $XLDATA | cut -d, -f7)
	CHANNEL=$(printf "%d" $CHANNEL)
	LBAND=$($ROOTER/chan2band.sh "$CHANNEL")
	if [ -n "$XLEC" ]; then
		BW=$(echo $XLEC | cut -d, -f3)
		RAWLIST=$(echo $XLEC | grep -o "BAND_LTE_[0-9]\{1,2\}.\+" | grep -o "[,0-9]*" | tr ',' ' ')
		BANDLIST=""
		NUMBR=0
		for BAND in $(echo "$RAWLIST"); do
			if [ -n "$BAND" -a "$BAND" != "0" ]; then
				NUMBR=$(($(echo $NUMBR) + 1))
				if [ -n "$BANDLIST" ]; then
					BANDLIST="$BANDLIST,$BAND"
				else
					BANDLIST="$BAND"
				fi
			fi
		done
		BAND="B"$(echo $BANDLIST | cut -d, -f1)
		if [ "$BAND" = "$LBAND" ]; then
			decode_bw
			LBAND=$LBAND" (Bandwidth $BW MHz)"
			for JJ in $(seq 2 $NUMBR); do
				BAND=$(echo $BANDLIST | cut -d, -f$JJ)
				if [ -n "$BAND" -a "$BAND" != "0" ]; then
					KK=$(($JJ + 2))
					BW=$(echo $XLEC | cut -d, -f$KK)
					decode_bw
					if [ $BW != "-" ]; then
						LBAND=$LBAND"<br />B$BAND (CA, Bandwidth $BW MHz)"
					fi
				fi
			done
			NBRrsrp=1
			for JJ in $(echo "$ATRSRP"); do
				if [ $NBRrsrp -gt 1 -a $NBRrsrp -le $NUMBR ]; then
					PCICA=$PCICA" "$(echo $JJ | cut -d, -f1)
					CHANCA=$CHANCA" "$(echo $JJ | cut -d, -f2)
					RSRPCA=$RSRPCA" "$(echo $JJ | cut -d, -f3)

				fi
				NBRrsrp=$((NBRrsrp + 1))
			done
		fi
	else
		XLEC=$(echo $OX | grep -o "+XLEC: 0,[1-9],[0-5]")
		if [ -n "$XLEC" ]; then
			BW=$(echo $XLEC | cut -d, -f3)
			decode_bw
			LBAND=$LBAND" (Bandwidth $BW MHz)"
		fi
	fi
	RSRP=$(echo $XLDATA | cut -d, -f10)
	if [ $RSRP == 0 ]; then
		RSRP=1
	fi
	RSCP=$(($RSRP - 141))
	ECIO=$(echo $XLDATA | cut -d, -f11)
	ECIO=$((($ECIO / 2) - 20))
	SINR=$(echo $XLDATA | cut -d, -f12 | grep -o "[-0-9]\{1,4\}")
	if [ -n "$SINR" ] && [ "$SINR" != "255" ]; then
		SINR=$(($SINR / 2))" dB"
	fi
	if [ -n "$BW" ]; then
		RSSI=$(rsrp2rssi $RSCP $BW)
		CSQ_PER=$((100 - (($RSSI + 51) * 100/-62)))"%"
		CSQ=$((($RSSI + 113) / 2))
		CSQ_RSSI=$RSSI" dBm"
	fi
fi

if [ -n "$XUDATA" ]; then
	MODE="UMTS"
	CHANNEL=$(echo $XUDATA | cut -d, -f7)
	CHANNEL=${CHANNEL:1:10}
	CHANNEL=$(printf "%d" $CHANNEL)
	RSCP=$(echo $XUDATA | cut -d, -f11)
	RSCP=$(($RSCP - 121))
	ECIO=$(echo $XUDATA | cut -d, -f12)
	ECIO=$((($ECIO / 2) - 24))
fi

if [ -n "$CADATA1" ]; then
	RSCP=""
	ECIO=""
	BW=$(echo $CADATA1 | cut -d, -f13)
	decode_bw
	BWD=$BW
	BW=$(echo $CADATA1 | cut -d, -f14)
	decode_bw
	BWU=$BW
	LBAND="B"$(echo $CADATA1 | cut -d, -f2)" (Bandwidth $BWD MHz Down | $BWU MHz Up)"
	CHANNEL=$(echo $CADATA1 | cut -d, -f11)
	MODE="LTE"
	CRAT="4"
	RSRP=$(echo $CADATA1 | cut -d, -f8)
	RSRQ=$(echo $CADATA1 | cut -d, -f9)
	if [ "$RSRP" -ne 255 ] && [ "$RSRQ" -ne 255 ]; then
		decode_signal
		RSSI=$(rsrp2rssi $RSCPs $BWD)
		CSQ_PER=$((100 - (($RSSI + 51) * 100/-62)))"%"
		CSQ=$((($RSSI + 113) / 2))
		CSQ_RSSI=$RSSI" dBm"
	else
		RSRP="-"
		RSRQ="-"
	fi
	PCI=$(echo $CADATA1 | cut -d, -f7)
fi

if [ -n "$CADATA2" ]; then
	CADATA2=$(echo "${CADATA2//[ ]/}")
	for CAVAL in $(echo "$CADATA2"); do
		BW=$(echo $CAVAL | cut -d, -f9)
		decode_bw
		BWD=$BW
		BW=$(echo $CAVAL | cut -d, -f10)
		decode_bw
		BWU=$BW
		LBAND=$LBAND"<br />B"$(echo $CAVAL | cut -d, -f2)
		if [ $BWU = "-" ]; then
			LBAND=$LBAND" (CA, Bandwidth: "$BWD" MHz)"
		else
			LBAND=$LBAND" (CA, Bandwidth $BWD MHz Down | $BWU MHz Up)"
		fi
		CHAN=$(echo $CAVAL | cut -d, -f7)
		CHANNEL=$(echo "$CHANNEL", "$CHAN")
		PCIX=$(echo $CAVAL | cut -d, -f3)
		PCI=$(echo "$PCI", "$PCIX")
	done
fi

if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
	CADATA3=""
fi
if [ -n "$CADATA3" ]; then
	CADATA3=$(echo "${CADATA3//[ ]/}")
	for CAVAL in $(echo "$CADATA3"); do
		BAND=$(echo $CAVAL | cut -d, -f3)
		BAND=${BAND:1}
		PCIX=$(echo $CAVAL | cut -d, -f4)
		PCI=$(echo "$PCI","$PCIX")
		CHAN=$(echo $CAVAL | cut -d, -f5)
		CHANNEL=$(echo "$CHANNEL","$CHAN")
		BW=$(echo $CAVAL | cut -d, -f6)
		if [ $BW -gt 14 ]; then
			BW=$((BW / 5))
		else
			BW="1.4"
		fi
		LBAND=$LBAND"<br />B"$(echo $BAND | sed 's/^0*//')" (CA, Bandwidth: "$BW" MHz)"
	done
fi

if [ -n "$CADATA4" ]; then
	NRCA=$(echo $CADATA4 | grep -o "PCC,[15]")
	CADATA4=$(echo $CADATA4 | grep -o "SCC[0-9][^S]\+")
	if [ -n "NRCA" ]; then
		CALIST4=$(echo $CADATA4 | grep -o "SCC[0-9]\{1,2\},2,[01],[15][0-9]\{2,4\},[0-9]\{1,3\},[0-9]\{1,6\},[0-9]\{1,3\},[0-9]\{1,3\},[^S]\+")
		for CAVAL in $(echo "$CALIST4"); do
			CAVAL=$CAVAL
			BAND=$(echo $CAVAL | cut -d, -f4)
			RATP=${BAND:0:1}
			if [ "$RATP" == "1" ]; then
				RATP="B"
			else
				RATP="n"
			fi
			UPLC=$(echo $CAVAL | cut -d, -f3)
			BWD=$(echo $CAVAL | cut -d, -f7)
			BWU=$(echo $CAVAL | cut -d, -f8)
			if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
				RSRP=$(echo $CAVAL | cut -d, -f14)
			else
				RSRP=$(echo $CAVAL | cut -d, -f13)
			fi
			SHOWBWU=true
		
			if [ $RATP == "B" ]; then
				if [ $BWD -gt 14 ]; then
					BWD=$((BWD / 5))
				else
					BWD="1.4"
				fi
				if [ "$BWU" -gt 100 ]; then
					BWU=100
				fi
				BWU=$((BWU / 5))
				if [ $BWU -lt 3 ]; then
					SHOWBWU=false
				fi
				CRAT="4"
			else
				if [ "$BWU" == "0" ]; then
					SHOWBWU=false
				fi
				if [ "$BWD" == "0" ]; then
					BWD="5"
				fi
				CRAT="9"
			fi
			if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
				RSRPX=$RSRP
			else
				if [ -n "$RSRP" ]; then
					ECIO=""
					decode_signal
				fi
			fi
			CHANNEL=$(echo "$CHANNEL","$(echo $CAVAL | cut -d, -f6)")
			PCI=$(echo "$PCI","$(echo $CAVAL | cut -d, -f5)")
			BAND=${BAND:1}
			if [ $UPLC == "1" ]; then
				LBAND=$LBAND"<br />$RATP"$(echo $BAND | sed 's/^0*//')" (CA"$(printf "\xe2\x86\x91")", Bandwidth: "$BWD" MHz down | "$BWU" MHz up)"
			elif $SHOWBWU; then
				LBAND=$LBAND"<br />$RATP"$(echo $BAND | sed 's/^0*//')" (CA, Bandwidth: "$BWD" MHz down | "$BWU" MHz up)"
			else
				LBAND=$LBAND"<br />$RATP"$(echo $BAND | sed 's/^0*//')" (CA, Bandwidth: "$BWD" MHz)"
			fi
		done
	fi
fi

if [ -z "$CADATA2" ] && [ -z "$CADATA3" ] && [ -z "$CADATA4" ]; then
	RSRPCA=$(echo $RSRPCA | tr " " ",")
	if [ -n "$RSRPCA" ]; then
		RSCP=$RSCP","$RSRPCA
	fi
	PCICA=$(echo $PCICA | tr " " ",")
	if [ -n "$PCICA" ]; then
		PCI=$PCI","$PCICA
	fi
	CHANCA=$(echo $CHANCA | tr " " ",")
	if [ -n "$CHANCA" ]; then
		CHANNEL=$CHANNEL","$CHANCA
	fi
fi
if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
	ATCMDD="AT+GTZONERDMAXTEMP=1"
	OXtm=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	ist=$(echo "$OXtm" | grep "+GTZONERDMAXTEMP: 1")
	if [ ! -z "$ist" ]; then
		CTEMP=$(echo $ist | cut -d, -f2)
		LENM=${#CTEMP}
		let LENM=$LENM-3
		CTEMP=${CTEMP:0:$LENM}$(printf "\xc2\xb0")"C"
	fi
else
	MTEMP=$(echo $OX | grep -o "+MTSM: [0-9.]\{1,5\}")
	if [ -n "$MTEMP" ]; then
		CTEMP=$(echo $MTEMP | grep -o "[0-9.]\{1,5\}")$(printf "\xc2\xb0")"C"
	fi
fi

MODTYPE="9"
MRAT=$(echo $OX | grep -o "+GTRAT: [0-9]\{1,2\}" | grep -o "[0-9]\{1,2\}")
if [ -n "$MRAT" ]; then
# If user inserted different SIM card, the Rat order will recover to default value (AT Commands manual)
	case $MRAT in
	"2" )
		NETMODE="5" ;;
	"3" )
		NETMODE="7" ;;
	"14" )
		NETMODE="9" ;;
	"17"|"20" )
		NETMODE="8" ;;
	* )
		NETMODE="1" ;;
	esac
fi
XACT=$(echo $OX | grep -o "+XACT: [0-9]" | grep -o "[0-9]")
if [ -n "$XACT" ]; then
	PREF=$(echo $OX | grep -o "+XACT: [0-9],[0-9]" | grep -o ",[0-9]")
	case $XACT in
	"1" )
		NETMODE="5" ;;
	"2" )
		NETMODE="7" ;;
	"4" )
		if [ "$PREF" = ",1" ]; then
			NETMODE="4"
		else
			NETMODE="6"
		fi ;;
	* )
		NETMODE="6" ;;
	esac
fi
CMODE=$(uci -q get modem.modem$CURRMODEM.cmode)
if [ "$CMODE" = 0 ]; then
	NETMODE="10"
fi
if [ -z "$SINR" ]; then
	SINR="-"
fi

{
	echo 'CSQ="'"$CSQ"'"'
	echo 'CSQ_PER="'"$CSQ_PER"'"'
	echo 'CSQ_RSSI="'"$CSQ_RSSI"'"'
	echo 'ECIO="'"$ECIO"'"'
	echo 'RSCP="'"$RSCP"'"'
	echo 'ECIO1="'"$ECIO1"'"'
	echo 'RSCP1="'"$RSCP1"'"'
	echo 'MODE="'"$MODE"'"'
	echo 'MODTYPE="'"$MODTYPE"'"'
	echo 'NETMODE="'"$NETMODE"'"'
	echo 'CHANNEL="'"$CHANNEL"'"'
	echo 'LBAND="'"$LBAND"'"'
	echo 'PCI="'"$PCI"'"'
	echo 'TEMP="'"$CTEMP"'"'
	echo 'SINR="'"$SINR"'"'
}  > /tmp/signal$CURRMODEM.file
if [ -n "$COPS_MCC" ]; then
	echo 'COPS_MCC="'"$COPS_MCC"'"' >> /tmp/signal$CURRMODEM.file
	echo 'COPS_MNC="'"$COPS_MNC"'"' >> /tmp/signal$CURRMODEM.file
fi
if [ "$idP" = 7127 -o "$idP" = 7126 ]; then
	COPX=$COPX
else
	if [ -n "$COPX" ]; then
		echo 'COPS="'"$COPX"'"' >> /tmp/signal$CURRMODEM.file
	fi
fi
