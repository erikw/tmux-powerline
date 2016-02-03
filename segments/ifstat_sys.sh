# Show if stats by sampling /sys/.
# Originally stolen from http://unix.stackexchange.com/questions/41346/upload-download-speed-in-tmux-status-line

run_segment() {
	sleeptime="0.5"
	if shell_is_osx; then
		iface="en0"
		RXB=$(netstat -i -b | grep -m 1 $iface | awk '{print $7}')
		TXB=$(netstat -i -b | grep -m 1 $iface | awk '{print $10}')
		sleep "$sleeptime"
		RXBN=$(netstat -i -b | grep -m 1 $iface | awk '{print $7}')
		TXBN=$(netstat -i -b | grep -m 1 $iface | awk '{print $10}')
	else
		iface="eth0"
		RXB=$(</sys/class/net/"$iface"/statistics/rx_bytes)
		TXB=$(</sys/class/net/"$iface"/statistics/tx_bytes)
		sleep "$sleeptime"
		RXBN=$(</sys/class/net/"$iface"/statistics/rx_bytes)
		TXBN=$(</sys/class/net/"$iface"/statistics/tx_bytes)
	fi
	RXDIF=$(echo "$((RXBN - RXB)) / 1024 / ${sleeptime}" | bc )
	TXDIF=$(echo "$((TXBN - TXB)) / 1024 / ${sleeptime}" | bc )

	if [ $RXDIF -gt 1024 ]; then
		RXDIF_ECHO="↓ $(echo "scale=1;${RXDIF} / 1024" | bc)M/s"
	else
		RXDIF_ECHO="↓ ${RXDIF}K/s"
	fi
	if [ $TXDIF -gt 1024 ]; then
		TXDIF_ECHO="↑ $(echo "scale=1;${TXDIF} / 1024" | bc)M/s"
	else
		TXDIF_ECHO="↑ ${TXDIF}K/s"
	fi

	echo -e "${RXDIF_ECHO} ${TXDIF_ECHO}"
	return 0
}
