# shellcheck shell=bash
# Print used disk space on the specified filesystem

TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM="${TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM:-/}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Filesystem to retrieve disk space information. Any from the filesystems available (run "df | awk '{print $1}'" to check them).
export TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM="${TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM}"
EORC
	echo "$rccontents"
}

run_segment() {
	percentage=$(df "${TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM}" | awk '{print $5}' | tail -n1)
	echo "${TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM} ${percentage}"
	return 0
}
