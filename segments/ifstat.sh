# shellcheck shell=bash
# Show network statistics for all active interfaces found.

TMUX_POWERLINE_SEG_IFSTAT_DOWN_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_DOWN_SYMBOL:-⇊}"
TMUX_POWERLINE_SEG_IFSTAT_UP_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_UP_SYMBOL:-⇈}"
TMUX_POWERLINE_SEG_IFSTAT_ETHERNET_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_ETHERNET_SYMBOL:-󰈀}"
TMUX_POWERLINE_SEG_IFSTAT_WLAN_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_WLAN_SYMBOL:-󱚻}"
TMUX_POWERLINE_SEG_IFSTAT_WWAN_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_WWAN_SYMBOL:-}"
TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_SEPARATOR="${TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_SEPARATOR:- | }"
TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_EXCLUDES="${TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_EXCLUDES:-^u?tun[0-9]+$}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Symbol for Download.
# export TMUX_POWERLINE_SEG_IFSTAT_DOWN_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_DOWN_SYMBOL}"
# Symbol for Upload.
# export TMUX_POWERLINE_SEG_IFSTAT_UP_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_UP_SYMBOL}"
# Symbol for Ethernet.
# export TMUX_POWERLINE_SEG_IFSTAT_ETHERNET_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_ETHERNET_SYMBOL}"
# Symbol for WLAN.
# export TMUX_POWERLINE_SEG_IFSTAT_WLAN_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_WLAN_SYMBOL}"
# Symbol for WWAN.
# export TMUX_POWERLINE_SEG_IFSTAT_WWAN_SYMBOL="${TMUX_POWERLINE_SEG_IFSTAT_WWAN_SYMBOL}"
# Separator for Interfaces.
# export TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_SEPARATOR="${TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_SEPARATOR}"
# Space separated list of interface names to be excluded. substring match, regexp can be used.
# Examples:
# export TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_EXCLUDES="tun" # will exclude 'tun0', 'utun0', 'itun', 'tun08127387'
# export TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_EXCLUDES="tun0 tuntun" # will exclude 'tun0', 'utun0', 'tuntun'
# export TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_EXCLUDES="^tun0$ ^tun1$" # excludes exactly 'tun0' and 'tun1'
# Default:
# export TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_EXCLUDES="${TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_EXCLUDES}"
EORC
	echo "$rccontents"
}

run_segment() {
	declare -a ifstat_seg
	local symbol_down
	local symbol_up
	if ! type ifstat >/dev/null 2>&1; then
		return 1
	fi

	symbol_down=$TMUX_POWERLINE_SEG_IFSTAT_DOWN_SYMBOL
	symbol_up=$TMUX_POWERLINE_SEG_IFSTAT_UP_SYMBOL

	read -r -a excludes <<<"$TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_EXCLUDES"
	data=$(ifstat -z -q 1 1)
	IFS=$'    ' read -r -a interfaces < <(echo -e "${data}" | head -n 1)
	IFS=$'    ' read -r -a flow_data < <(echo -e "${data}" | tail -n 1)
	index=0
	for inf in "${interfaces[@]}"; do
		for excl in "${excludes[@]}"; do
			[[ "$inf" =~ $excl ]] && continue 2
		done
		type=""
		case ${inf} in
		eth* | en*)
			type="$TMUX_POWERLINE_SEG_IFSTAT_ETHERNET_SYMBOL"
			;;
		wl*)
			type="$TMUX_POWERLINE_SEG_IFSTAT_WLAN_SYMBOL"
			;;
		ww*)
			type="$TMUX_POWERLINE_SEG_IFSTAT_WWAN_SYMBOL"
			;;
		*)
			type="${inf:0:3}*"
			;;
		esac
		ifstat_seg+=("$(printf "$type $symbol_down %.1f $symbol_up %.1f" "${flow_data[$index]}" "${flow_data[$((index + 1))]}")")
		index=$((index + 2))
	done
	if [ "${#ifstat_seg}" -gt 0 ]; then
		output=""
		for ((i = 0; i < "${#ifstat_seg[@]}"; i++)); do
			[ "$i" -gt 0 ] && output="${output}${TMUX_POWERLINE_SEG_IFSTAT_INTERFACE_SEPARATOR}"
			output="${output}${ifstat_seg[$i]}"
		done
		echo "$output"
	fi
	return 0
}
