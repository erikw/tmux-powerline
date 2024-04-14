# shellcheck shell=bash
# Check script arguments.

check_arg_segment() {
	local segment="$1"
	if ! [[ "$segment" == "left" || "$segment" == "right" || "$segment" == "window-current-format" || "$segment" == "window-format" ]]; then
		echo "Argument must be the side to handle {left, right}, or {window-current-format, window-format}, not \"${segment}\"."
		exit 1
	fi
}
