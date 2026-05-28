# shellcheck shell=bash
# Prints the WAN IP address. The result is cached and updated according to $update_period.
#
# Network fetch is done in a background process so tmux rendering is never blocked.
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
	local lock_file="${TMUX_POWERLINE_DIR_TEMPORARY}/wan_ip_refresh.lock"
	local update_period=900
	local wan_ip

	# Always return cached data immediately, even if stale
	if [ -f "$tmp_file" ]; then
		wan_ip=$(cat "$tmp_file")
	fi

	# Check if cache is stale or missing; if so, refresh in background
	if ! __wan_ip_cache_is_fresh "$tmp_file" "$update_period"; then
		# Stale-lock check: if lock is older than the maximum possible fetch time, treat it as abandoned
		if [ -f "$lock_file" ]; then
			local lock_mtime lock_age=0
			lock_mtime=$(stat -c "%Y" "$lock_file" 2>/dev/null || stat -f "%m" "$lock_file" 2>/dev/null)
			[ -n "$lock_mtime" ] && lock_age=$(( $(date +%s) - lock_mtime ))
			if [ "$lock_age" -gt 10 ]; then
				rm -f "$lock_file"
			fi
		fi
		# Atomically acquire the lock; bail out if another invocation beat us to it
		if ( set -o noclobber; > "$lock_file" ) 2>/dev/null; then
			(
				exec >/dev/null 2>&1
				trap 'rm -f "$lock_file"' EXIT
				local fresh_ip
				if fresh_ip=$(curl --max-time 2 -s https://whatismyip.akamai.com/); then
					echo "${fresh_ip}" > "$tmp_file"
				fi
			) &
			disown
		fi
	fi

	if [ -n "$wan_ip" ]; then
		echo "#[fg=$TMUX_POWERLINE_SEG_WAN_IP_SYMBOL_COLOUR]${TMUX_POWERLINE_SEG_WAN_IP_SYMBOL}#[fg=$TMUX_POWERLINE_CUR_SEGMENT_FG]${wan_ip}"
	fi

	return 0
}

__wan_ip_cache_is_fresh() {
	local tmp_file="$1"
	local update_period="$2"
	[ -f "$tmp_file" ] || return 1
	local last_update time_now
	if tp_shell_is_macos || tp_shell_is_bsd; then
		stat >/dev/null 2>&1 && is_gnu_stat=false || is_gnu_stat=true
		if [ "$is_gnu_stat" == "true" ]; then
			last_update=$(stat -c "%Y" "$tmp_file")
		else
			last_update=$(stat -f "%m" "$tmp_file")
		fi
	else
		last_update=$(stat -c "%Y" "$tmp_file")
	fi
	time_now=$(date +%s)
	[ "$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)" -eq 1 ]
}
