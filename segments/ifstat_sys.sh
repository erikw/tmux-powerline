# shellcheck shell=bash
# Show if stats by sampling /sys/.
# Originally stolen from http://unix.stackexchange.com/questions/41346/upload-download-speed-in-tmux-status-line

run_segment() {
	sleeptime="0.5"
	if shell_is_osx; then
		iface=$(route get default | grep -i interface | awk '{print $2}')
		if [ -z "$iface" ]; then
			iface="en0"
		fi
		type="⎆" # "☫" for wlan
		RXB=$(netstat -i -b | grep -m 1 "$iface" | awk '{print $7}')
		TXB=$(netstat -i -b | grep -m 1 "$iface" | awk '{print $10}')
		sleep "$sleeptime"
		RXBN=$(netstat -i -b | grep -m 1 "$iface" | awk '{print $7}')
		TXBN=$(netstat -i -b | grep -m 1 "$iface" | awk '{print $10}')
	else
		iface=$(ip route show default | grep -o "dev.*" | cut -d ' ' -f 2)
		if [ -z "$iface" ]; then
			iface=$(awk '{if($2>0 && NR > 2) print substr($1, 0, index($1, ":") - 1)}' /proc/net/dev | sed '/^lo$/d')
		fi
		type="⎆" # "☫" for wlan
		RXB=$(</sys/class/net/"$iface"/statistics/rx_bytes)
		TXB=$(</sys/class/net/"$iface"/statistics/tx_bytes)
		sleep "$sleeptime"
		RXBN=$(</sys/class/net/"$iface"/statistics/rx_bytes)
		TXBN=$(</sys/class/net/"$iface"/statistics/tx_bytes)
	fi
	RXDIF=$(echo "$((RXBN - RXB)) / 1024 / ${sleeptime}" | bc)
	TXDIF=$(echo "$((TXBN - TXB)) / 1024 / ${sleeptime}" | bc)

	if [ "$RXDIF" -gt 1024 ]; then
		RXDIF=$(echo "scale=1;${RXDIF} / 1024" | bc)
		RXDIF_UNIT="M/s"
	else
		RXDIF_UNIT="K/s"
	fi
	if [ "$TXDIF" -gt 1024 ]; then
		TXDIF=$(echo "scale=1;${TXDIF} / 1024" | bc)
		TXDIF_UNIT="M/s"
	else
		TXDIF_UNIT="K/s"
	fi

	# NOTE: '%5.01' for fixed length always
	printf "${type} ⇊ %5.01f${RXDIF_UNIT} ⇈ %5.01f${TXDIF_UNIT}" "${RXDIF}" "${TXDIF}"
	return 0
}
