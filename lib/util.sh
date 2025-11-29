# shellcheck shell=bash

tp_is_flag_enabled() {
	local flag_value="$1"

	case "$(awk '{print tolower($0)}' <<<"${flag_value}")" in
	on | true | y | yes | 1)
		return 0
		;;
	*)
		return 1
		;;
	esac
}

tp_is_tmp_valid() {
	local tmp_file="$1"
	local tmp_validity="$2"

	if [ -f "$tmp_file" ]; then
		if tp_shell_is_macos || tp_shell_is_bsd; then
			stat >/dev/null 2>&1 && is_gnu_stat=false || is_gnu_stat=true
			if [ "$is_gnu_stat" == "true" ]; then
				last_update=$(stat -c "%Y" "${tmp_file}")
			else
				last_update=$(stat -f "%m" "${tmp_file}")
			fi
		elif tp_shell_is_linux || [ -z "$is_gnu_stat" ]; then
			last_update=$(stat -c "%Y" "${tmp_file}")
		fi

		time_now=$(date +%s)
		valid=$(echo "(${time_now}-${last_update}) < ${tmp_validity}" | bc)

		if [ "$valid" -eq 1 ]; then
			return 0
		else
			return 1
		fi
	else
		return 1
	fi

}

tp_command_exists() {
	command -v "$1" >/dev/null
}

tp_err() {
	if [ "$TMUX_POWERLINE_ERROR_LOGS_ENABLED" != "false" ]; then
		local scope="$1"
		shift
		if [ "$TMUX_POWERLINE_ERROR_LOGS_SCOPES" != "" ]; then
			# split by word and log the respective file
			if [[ "$TMUX_POWERLINE_ERROR_LOGS_SCOPES" =~ ( |^)$scope( |$) ]]; then
				echo "[$(date)] $*" >> "${TMUX_POWERLINE_DIR_TEMPORARY}/${scope//\//_}_error.log"
			fi
		else
			echo "[$(date)][$scope] $*" >> "${TMUX_POWERLINE_DIR_TEMPORARY}/error.log"
		fi
	fi
}

tp_err_seg() {
	# TMUX_POWERLINE_CUR_SEGMENT_NAME is being set before each segment run
	tp_err "${TMUX_POWERLINE_CUR_SEGMENT_NAME:-unknown_segment}" "$*"
}

# source https://askubuntu.com/a/179949
# Rounds positive numbers up to the number of digits to the right of the decimal point.
# Example: "tp_round 1.2345 3" -> "((1000 * 1.2345) + 0.5) / 1000" -> "1.235"
tp_round() {
	local number="$1"
	local digits="$2"

	env printf "%.${digits}f" "$(echo "scale=${digits};(((10^${digits})*${number})+0.5)/(10^${digits})" | bc)"
};


# Get tmux-powerline version.
tp_version() {
	grep release: "$TMUX_POWERLINE_DIR_HOME/.semver.yaml" | cut -d' ' -f2
}
