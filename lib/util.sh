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
