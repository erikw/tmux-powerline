#!/usr/bin/env bash
# Show if stats by sampling /sys/.
# Originally stolen from http://unix.stackexchange.com/questions/41346/upload-download-speed-in-tmux-status-line

sleeptime="0.5"
iface="wlan0"
RXB=$(</sys/class/net/"$iface"/statistics/rx_bytes)
TXB=$(</sys/class/net/"$iface"/statistics/tx_bytes)
sleep "$sleeptime" 
RXBN=$(</sys/class/net/"$iface"/statistics/rx_bytes)
TXBN=$(</sys/class/net/"$iface"/statistics/tx_bytes)
RXDIF=$(echo $((RXBN - RXB)) )
TXDIF=$(echo $((TXBN - TXB)) )

#echo -e "$((RXDIF / 1024 / ${sleeptime}))K/s $((TXDIF / 1024 / ${sleeptime}))K/s"
rx=$(echo "${RXDIF} / 1024 / ${sleeptime}" | bc)
tx=$(echo "${TXDIF} / 1024 / ${sleeptime}" | bc)
echo -e "⇊ ${rx}K/s ⇈ ${tx}K/s"

exit 0
