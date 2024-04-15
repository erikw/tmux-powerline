# shellcheck shell=bash
# Prints the local network IPv4 address for a statically defined NIC or search for an IPv4 address on all active NICs.
TMUX_POWERLINE_SEG_LAN_IP_SYMBOL="${TMUX_POWERLINE_SEG_LAN_IP_SYMBOL:-ⓛ }"
TMUX_POWERLINE_SEG_LAN_IP_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_LAN_IP_SYMBOL_COLOUR:-255}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Symbol for LAN IP.
# export TMUX_POWERLINE_SEG_LAN_IP_SYMBOL="${TMUX_POWERLINE_SEG_LAN_IP_SYMBOL}"
# Symbol colour for LAN IP
# export TMUX_POWERLINE_SEG_LAN_IP_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_LAN_IP_SYMBOL_COLOUR}"
EORC
	echo "$rccontents"
}

run_segment() {
	if shell_is_bsd || shell_is_osx; then
		default_route_nic=$(route get default | grep -i interface | awk '{print $2}')
		all_nics=$(ifconfig 2>/dev/null | awk -F':' '/^[a-z]/ && !/^lo/ { print $1 }' | tr '\n' ' ')
		IFS=' ' read -ra all_nics_array <<<"$all_nics"
		# the nic of the default route is considered first
		all_nics_array=("$default_route_nic" "${all_nics_array[@]}")
		for nic in "${all_nics_array[@]}"; do
			ipv4s_on_nic=$(ifconfig "${nic}" 2>/dev/null | awk '$1 == "inet" { print $2 }')
			for lan_ip in "${ipv4s_on_nic[@]}"; do
				[[ -n "${lan_ip}" ]] && break
			done
			[[ -n "${lan_ip}" ]] && break
		done
	else
		default_route_nic=$(ip route get 1.1.1.1 | grep -o "dev.*" | cut -d ' ' -f 2)
		# Get the names of all attached NICs.
		all_nics="$(ip addr show | cut -d ' ' -f2 | tr -d :)"
		all_nics=("${all_nics[@]/lo/}") # Remove lo interface.
		# the nic of the default route is considered first
		all_nics=("$default_route_nic" "${all_nics[@]}")

		for nic in "${all_nics[@]}"; do
			# Parse IP address for the NIC.
			lan_ip="$(ip addr show "${nic}" | grep '\<inet\>' | tr -s ' ' | cut -d ' ' -f3)"
			# Trim the CIDR suffix.
			lan_ip="${lan_ip%/*}"
			# Only display the last entry
			lan_ip="$(echo "$lan_ip" | tail -1)"

			[ -n "$lan_ip" ] && break
		done
	fi

	echo "#[fg=$TMUX_POWERLINE_SEG_LAN_IP_SYMBOL_COLOUR]${TMUX_POWERLINE_SEG_LAN_IP_SYMBOL}#[fg=$TMUX_POWERLINE_CUR_SEGMENT_FG]${lan_ip-N/a}"
	return 0
}
