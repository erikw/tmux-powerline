# shellcheck shell=bash
# Prints memory usage

TMUX_POWERLINE_SEG_MEM_USED_ICON_DEFAULT=" "
TMUX_POWERLINE_SEG_MEM_USED_UNIT_DEFAULT="GB"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Memory icon
export TMUX_POWERLINE_SEG_MEM_USED_ICON="${TMUX_POWERLINE_SEG_MEM_USED_ICON_DEFAULT}"
# Measure unit of memory: "GB" or "MB".
# In context of this segment "1 GB" equals "2 ^ 30 bytes" and "1 MB" eqauls "2 ^ 20 bytes".
export TMUX_POWERLINE_SEG_MEM_USED_UNIT="${TMUX_POWERLINE_SEG_MEM_USED_UNIT_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings

	local mem_used

	if [ "$TMUX_POWERLINE_SEG_MEM_USED_UNIT" = "GB" ]; then
		mem_used="$(tp_mem_used_gigabytes) GB"
	elif [ "$TMUX_POWERLINE_SEG_MEM_USED_UNIT" = "MB" ]; then
		mem_used="$(tp_mem_used_megabytes) MB"
	else
		tp_err_seg "Err: Invalid TMUX_POWERLINE_SEG_MEM_USED_UNIT value - $TMUX_POWERLINE_SEG_MEM_USED_UNIT"
		return 1
	fi

	if [ -n "$mem_used" ]; then
		echo "${TMUX_POWERLINE_SEG_MEM_USED_ICON}${mem_used}"
		return 0
	else
		tp_err_seg "Err: Failed to obtain memory usage"
		return 1
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_MEM_USED_ICON" ]; then
		export TMUX_POWERLINE_SEG_MEM_USED_ICON="${TMUX_POWERLINE_SEG_MEM_USED_ICON_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MEM_USED_UNIT" ]; then
		export TMUX_POWERLINE_SEG_MEM_USED_UNIT="${TMUX_POWERLINE_SEG_MEM_USED_UNIT_DEFAULT}"
	fi
};

