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
		mem_used="$(__round "$(tp_mem_used_gigabytes)" 2) GB"
	else
		mem_used="$(__round "$(tp_mem_used_megabytes)" 0) MB"
	fi

	if [ -n "$mem_used" ]; then
		echo "${TMUX_POWERLINE_SEG_MEM_USED_ICON}${mem_used}"
		return 0
	else
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

# source https://askubuntu.com/a/179949
__round() {
	printf "%.$2f" "$(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc)"
};

