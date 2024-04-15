# shellcheck shell=bash
# Prints local vpn tunnel address
TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE="${TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE:-both}"
TMUX_POWERLINE_SEG_VPN_NICS="${TMUX_POWERLINE_SEG_VPN_NICS:-^u?tun[0-9]+$}"
TMUX_POWERLINE_SEG_VPN_SYMBOL="${TMUX_POWERLINE_SEG_VPN_SYMBOL:-󱠾 }"
TMUX_POWERLINE_SEG_VPN_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VPN_SYMBOL_COLOUR:-255}"
TMUX_POWERLINE_SEG_VPN_DISPLAY_SEPARATOR="${TMUX_POWERLINE_SEG_VPN_DISPLAY_SEPARATOR:-󰿟}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Mode for VPN segment {"both", "ip", "name"}. both: Show NIC/IP; ip: Show only IP; name: Show only NIC name
# export TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE="${TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE}"
# Space separated list of tunnel interface names. First match is being used. substring match, regexp can be used.
# Examples:
# export TMUX_POWERLINE_SEG_VPN_NICS="tun" # will match 'tun0', 'utun0', 'itun', 'tun08127387'
# export TMUX_POWERLINE_SEG_VPN_NICS="tun0 tuntun" # will match 'tun0', 'utun0', 'tuntun'
# export TMUX_POWERLINE_SEG_VPN_NICS="^tun0$ ^tun1$" # exactly 'tun0' and 'tun1'
# Default:
# export TMUX_POWERLINE_SEG_VPN_NICS='${TMUX_POWERLINE_SEG_VPN_NICS}'
# Symbol to use for vpn tunnel.
# export TMUX_POWERLINE_SEG_VPN_SYMBOL="${TMUX_POWERLINE_SEG_VPN_SYMBOL}"
# Colour for vpn tunnel symbol
# export TMUX_POWERLINE_SEG_VPN_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VPN_SYMBOL_COLOUR}"
# Symbol for separator
# export TMUX_POWERLINE_SEG_VPN_DISPLAY_SEPARATOR="${TMUX_POWERLINE_SEG_VPN_DISPLAY_SEPARATOR}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	read -r -a nics < <(echo "${TMUX_POWERLINE_SEG_VPN_NICS}")

	# output variables
	display_nic_name=""
	display_nic_ip=""

	# different handling for mac/bsd and linux
	if shell_is_bsd || shell_is_osx; then
		# iterate through interface list
		while read -r line; do
			# check if line is interface
			if [[ "$line" =~ ^[a-zA-Z0-9_-]+:\ flags= ]]; then
				# in case we had a matching name or ip before, reset.
				display_nic_name=""
				display_nic_ip=""

				# we only need the part before the first ":"
				nic="${line/:*/}"
				for _cnic in "${nics[@]}"; do
					if [[ "$nic" =~ $_cnic ]]; then
						display_nic_name="$nic"
						break
					fi
				done

			fi
			# only proceed if we match inet line and already have a name set
			if [[ "$line" =~ inet\ [0-9.]+ ]] && [ "$display_nic_name" != "" ]; then
				read -r _unused display_nic_ip _unused < <(echo "$line")
				break
			fi
		done < <(ifconfig)

	else
		while read -r line; do
			# check if line is interface
			if [[ "$line" =~ ^[0-9]+: ]]; then
				# in case we had a matching name or ip before, reset.
				display_nic_name=""
				display_nic_ip=""

				read -r _unused nic _unused < <(echo "$line")
				nic="${nic/:*/}"
				for _cnic in "${nics[@]}"; do
					if [[ "$nic" =~ $_cnic ]]; then
						display_nic_name="$nic"
						break
					fi
				done
			fi

			# only proceed if we match inet line and already have a name set
			if [[ "$line" =~ inet\ [0-9.]+\/[0-9]+ ]] && [ "$display_nic_name" != "" ]; then
				read -r _unused _ip _unused < <(echo "$line")
				display_nic_ip="${_ip/\/*/}"
				break
			fi
		done < <(ip a)
	fi

	if [ -n "${display_nic_name}" ] && [ -n "${display_nic_ip}" ]; then
		display="#[fg=colour${TMUX_POWERLINE_SEG_VPN_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_VPN_SYMBOL}#[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]"
		if [ "${TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE}" = "both" ]; then
			echo -n "${display}${display_nic_name}${TMUX_POWERLINE_SEG_VPN_DISPLAY_SEPARATOR}${display_nic_ip}"
		elif [ "${TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE}" = "ip" ]; then
			echo -n "${display}${display_nic_ip}"
		elif [ "${TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE}" = "name" ]; then
			echo -n "${display}${display_nic_name}"
		fi
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE" ]; then
		export TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE="${TMUX_POWERLINE_SEG_VPN_DISPLAY_MODE}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VPN_NICS" ]; then
		export TMUX_POWERLINE_SEG_VPN_NICS="${TMUX_POWERLINE_SEG_VPN_NICS}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VPN_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VPN_SYMBOL="${TMUX_POWERLINE_SEG_VPN_SYMBOL}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VPN_SYMBOL_COLOUR" ]; then
		export TMUX_POWERLINE_SEG_VPN_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VPN_SYMBOL_COLOUR}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VPN_DISPLAY_SEPARATOR" ]; then
		export TMUX_POWERLINE_SEG_VPN_DISPLAY_SEPARATOR="${TMUX_POWERLINE_SEG_VPN_DISPLAY_SEPARATOR}"
	fi
}
