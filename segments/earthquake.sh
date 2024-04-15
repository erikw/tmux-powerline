# shellcheck shell=bash
# Prints the most recent earthquake (currently only supports japan)
# It prints the location, time, and magnitude if the quake happened within
# a timelimit and magnitude threshold

earthquake_symbol='#[fg=colour1]~'

# The update period in seconds.
update_period=600

TMUX_POWERLINE_SEG_EARTHQUAKE_DATA_PROVIDER_DEFAULT="goo"
TMUX_POWERLINE_SEG_EARTHQUAKE_UPDATE_PERIOD_DEFAULT="600"
TMUX_POWERLINE_SEG_EARTHQUAKE_ALERT_TIME_WINDOW_DEFAULT="60"
TMUX_POWERLINE_SEG_EARTHQUAKE_TIME_FORMAT_DEFAULT='(%H:%M)'
TMUX_POWERLINE_SEG_EARTHQUAKE_MIN_MAGNITUDE_DEFAULT='3'

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# The data provider to use. Currently only "goo" is supported.
export TMUX_POWERLINE_SEG_EARTHQUAKE_DATA_PROVIDER="${TMUX_POWERLINE_SEG_EARTHQUAKE_DATA_PROVIDER_DEFAULT}"
# How often to update the earthquake data in seconds.
# Note: This is not an early warning detector, use this
# to be informed about recent earthquake magnitudes in your
# area. If this is too often, goo may decide to ban you form
# their server
export TMUX_POWERLINE_SEG_EARTHQUAKE_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_EARTHQUAKE_UPDATE_PERIOD_DEFAULT}"
# Only display information when earthquakes are within this many minutes
export TMUX_POWERLINE_SEG_EARTHQUAKE_ALERT_TIME_WINDOW="${TMUX_POWERLINE_SEG_EARTHQUAKE_ALERT_TIME_WINDOW_DEFAULT}"
# Display time with this format
export TMUX_POWERLINE_SEG_EARTHQUAKE_TIME_FORMAT='${TMUX_POWERLINE_SEG_EARTHQUAKE_TIME_FORMAT_DEFAULT}'
# Display only if magnitude is greater or equal to this number
export TMUX_POWERLINE_SEG_EARTHQUAKE_MIN_MAGNITUDE="${TMUX_POWERLINE_SEG_EARTHQUAKE_MIN_MAGNITUDE_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/earthquake.txt"
	local earthquake
	case "$TMUX_POWERLINE_SEG_EARTHQUAKE_DATA_PROVIDER" in
	"goo") earthquake=$(__goo_earthquake) ;;
	*)
		echo "Unknown earthquake-information provider [$TMUX_POWERLINE_SEG_EARTHQUAKE_DATA_PROVIDER]"
		return 1
		;;
	esac
	if [ -n "$earthquake" ]; then
		echo "$earthquake_symbol #[fg=colour237]${earthquake}"
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_EARTHQUAKE_DATA_PROVIDER" ]; then
		export TMUX_POWERLINE_SEG_EARTHQUAKE_DATA_PROVIDER="${TMUX_POWERLINE_SEG_EARTHQUAKE_DATA_PROVIDER_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_EARTHQUAKE_UPDATE_PERIOD" ]; then
		export TMUX_POWERLINE_SEG_EARTHQUAKE_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_EARTHQUAKE_UPDATE_PERIOD_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_EARTHQUAKE_ALERT_TIME_WINDOW" ]; then
		export TMUX_POWERLINE_SEG_EARTHQUAKE_ALERT_TIME_WINDOW="${TMUX_POWERLINE_SEG_EARTHQUAKE_ALERT_TIME_WINDOW_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_EARTHQUAKE_TIME_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_EARTHQUAKE_TIME_FORMAT="${TMUX_POWERLINE_SEG_EARTHQUAKE_TIME_FORMAT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_EARTHQUAKE_MIN_MAGNITUDE" ]; then
		export TMUX_POWERLINE_SEG_EARTHQUAKE_MIN_MAGNITUDE="${TMUX_POWERLINE_SEG_EARTHQUAKE_MIN_MAGNITUDE_DEFAULT}"
	fi
}

__goo_earthquake() {
	location=""
	magnitude=""
	magnitude_number=""
	timestamp=""
	if [[ -f "$tmp_file" ]]; then
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" "${tmp_file}")
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" "${tmp_file}")
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			__read_tmp_file
		fi
	fi

	if [ -z "$magnitude" ]; then
		# get the rss file, convert encoding to UTF-8, then delete windows carriage-returns
		if earthquake_data=$(curl --max-time 4 -s "http://weather.goo.ne.jp/earthquake/index.rdf" | iconv -f EUC-JP -t UTF-8 | tr -d "\r"); then
			# This rss feed is not very clean or easy to use, but we will use it because
			# this is all that can be found for now

			# we grab the data from the title of the first item (most recent earthquake)
			earthquake_data=${earthquake_data#*item\><title>}
			# end our data at the end of the approx. time
			earthquake_data=${earthquake_data%%頃*}

			# pluck our data
			location=$(echo "$earthquake_data" | awk '{print $2}')
			magnitude=$(echo "$earthquake_data" | awk '{print $4}')
			timestamp=${earthquake_data#*\(}

			__convert_jp_magnitude
			__convert_jp_timestamp

			echo "$location" >"$tmp_file"
			echo "$magnitude" >>"$tmp_file"
			echo "$timestamp" >>"$tmp_file"
		elif [ -f "$tmp_file" ]; then
			__read_tmp_file
		fi
	fi
	__convert_timestamp_to_fmt

	# extract the numerical portion of magnitude
	magnitude_number=$(echo "$magnitude" | sed -e 's/+//' -e 's/-//')

	if [ -n "$magnitude" ]; then
		if __check_alert_time_window && __check_min_magnitude; then
			echo "${location}${timestamp_fmt}:#[fg=colour0]${magnitude}"
		fi
	fi
}

__convert_jp_magnitude() {
	magnitude=${magnitude#震度}
	# simplify high-lower designation (only used in extreme cases: above 4)
	if [[ "$magnitude" == *弱 ]]; then
		magnitude="-${magnitude%弱}"
	elif [[ "$magnitude" == *強 ]]; then
		magnitude="+${magnitude%強}"
	fi
}

__check_alert_time_window() {
	[[ $((($(date +%s) - timestamp) / 60)) -lt $TMUX_POWERLINE_SEG_EARTHQUAKE_ALERT_TIME_WINDOW ]]
}

__check_min_magnitude() {
	[[ $magnitude_number -ge $TMUX_POWERLINE_SEG_EARTHQUAKE_MIN_MAGNITUDE ]]
}

__convert_jp_timestamp() {
	if shell_is_osx; then
		timestamp=$(date -j -f "%Y年%m月%d日 %H時%M分" "$timestamp" +"%s")
	else
		timestamp=$(echo "$timestamp" | sed -e 's/年/-/' -e 's/月/-/' -e 's/日//' -e 's/時/:/' -e 's/分//')
		timestamp=$(date -d "$timestamp" +"%s")
	fi
}

__convert_timestamp_to_fmt() {
	if shell_is_osx; then
		timestamp_fmt=$(date -r "$timestamp" +"$TMUX_POWERLINE_SEG_EARTHQUAKE_TIME_FORMAT")
	else
		timestamp_fmt=$(date -d "$timestamp" +"$TMUX_POWERLINE_SEG_EARTHQUAKE_TIME_FORMAT")
	fi
}

__read_tmp_file() {
	if [ ! -f "$tmp_file" ]; then
		return
	fi
	IFS_bak="$IFS"
	IFS=$'\n'
	read -r -a lines <<<"${tmp_file}"
	IFS="$IFS_bak"
	location="${lines[0]}"
	magnitude="${lines[1]}"
	timestamp="${lines[2]}"
}
