# Prints the local network IPv4 address for a statically defined NIC or search for an IPv4 address on all active NICs.
# vi: sw=8 ts=8 noet

run_segment() {
	if shell_is_bsd; then
		all_nics=$(ifconfig 2>/dev/null | awk -F':' '/^[a-z]/ && !/^lo/ { print $1 }')
		for nic in ${all_nics[@]}; do
			ipv4s_on_nic=$(ifconfig ${nic} 2>/dev/null | awk '$1 == "inet" { print $2 }')
			for lan_ip in ${ipv4s_on_nic[@]}; do
				[[ -n "${lan_ip}" ]] && break
			done
			[[ -n "${lan_ip}" ]] && break
		done
	else
		# Get the names of all attached NICs.
		all_nics=$(ip addr show | cut -d ' ' -f2 | tr -d :)
		all_nics=(${all_nics[@]//lo/})	 # Remove lo interface.

		for nic in ${all_nics[@]}; do
			# Parse IP address for the NIC.
			lan_ip=$(ip addr show ${nic} | grep '\<inet\>' | tr -s ' ' | cut -d ' ' -f3)
			# Trim the CIDR suffix.
			lan_ip=${lan_ip%/*}

			[ -n "$lan_ip" ] && break
		done
	fi

	if [ -n "$lan_ip" ]; then
		echo "ⓛ ${lan_ip}"
		return 0
	else
		return 1
	fi
}
