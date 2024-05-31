# shellcheck shell=bash
# Prints the WAN IP address. The result is cached and updated according to $update_period.
TMUX_POWERLINE_SEG_WAN_IP_SYMBOL="${TMUX_POWERLINE_SEG_WAN_IP_SYMBOL:-ⓦ }"
TMUX_POWERLINE_SEG_WAN_IP_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_WAN_IP_SYMBOL_COLOUR:-255}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Symbol for WAN IP
# export TMUX_POWERLINE_SEG_WAN_IP_SYMBOL="${TMUX_POWERLINE_SEG_WAN_IP_SYMBOL}"
# Symbol colour for WAN IP
# export TMUX_POWERLINE_SEG_WAN_IP_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_WAN_IP_SYMBOL_COLOUR}"
EORC
	echo "$rccontents"
}

run_segment() {
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/wan_ip.txt"
	local wan_ip

	if [ -f "$tmp_file" ]; then
		if shell_is_osx || shell_is_bsd; then
			stat >/dev/null 2>&1 && is_gnu_stat=false || is_gnu_stat=true
			if [ "$is_gnu_stat" == "true" ]; then
				last_update=$(stat -c "%Y" "${tmp_file}")
			else
				last_update=$(stat -f "%m" "${tmp_file}")
			fi
		elif shell_is_linux || [ -z "$is_gnu_stat" ]; then
			last_update=$(stat -c "%Y" "${tmp_file}")
		fi

		time_now=$(date +%s)
		update_period=900
		up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)

		if [ "$up_to_date" -eq 1 ]; then
			wan_ip=$(cat "${tmp_file}")
		fi
	fi

	if [ -z "$wan_ip" ]; then
		if wan_ip=$(curl --max-time 2 -s https://whatismyip.akamai.com/); then
			echo "${wan_ip}" >"$tmp_file"
		elif [ -f "${tmp_file}" ]; then
			wan_ip=$(cat "$tmp_file")
		fi
	fi

	if [ -n "$wan_ip" ]; then
		echo "#[fg=$TMUX_POWERLINE_SEG_WAN_IP_SYMBOL_COLOUR]${TMUX_POWERLINE_SEG_WAN_IP_SYMBOL}#[fg=$TMUX_POWERLINE_CUR_SEGMENT_FG]${wan_ip}"
	fi

	return 0
}
