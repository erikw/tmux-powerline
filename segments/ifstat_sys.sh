# Show if stats by sampling /sys/.
# Originally stolen from http://unix.stackexchange.com/questions/41346/upload-download-speed-in-tmux-status-line

run_segment() {
	sleeptime="0.5"
	iface="wlan0"
	RXB=$(</sys/class/net/"$iface"/statistics/rx_bytes)
	TXB=$(</sys/class/net/"$iface"/statistics/tx_bytes)
	sleep "$sleeptime" 
	RXBN=$(</sys/class/net/"$iface"/statistics/rx_bytes)
	TXBN=$(</sys/class/net/"$iface"/statistics/tx_bytes)
	RXDIF=$(echo $((RXBN - RXB)) )
	TXDIF=$(echo $((TXBN - TXB)) )

	rx=$(echo "${RXDIF} / 1024 / ${sleeptime}" | bc)
	tx=$(echo "${TXDIF} / 1024 / ${sleeptime}" | bc)
	echo -e "⇊ ${rx}K/s ⇈ ${tx}K/s"

	return 0
}
