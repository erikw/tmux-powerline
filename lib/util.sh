# shellcheck shell=bash

is_flag_enabled() {
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

is_tmp_valid() {
	local tmp_file="$1"
	local tmp_validity="$2"

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
