# shellcheck shell=bash
# Adapter for tmux-continuum (https://github.com/tmux-plugins/tmux-continuum) to show save state.
# This replaces manually putting "#{continuum_status}" in your status-(left|right) as instructed in the continuum README.md.

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

# TODO where does TMUX_PLUGIN_MANAGER comes from, is it reliable to use? only avail inside tmux, then can't use as config of tmux-powerline could be used outside tmux.
TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT="${TMUX_PLUGIN_MANAGER_PATH}/tmux-continuum"
# TODO option for custom prefix message, I want only "Continuum: "

TMUX_CONTINUUM_STATUS_SCRIPT_RELPATH="scripts/continuum_status.sh"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Path to the tmux-continuum git repo.
export TMUX_CONTINUUM_PATH="${TMUX_PLUGIN_MANAGER_PATH}/tmux-continuum"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	local status=""

	if [ -x "$TMUX_CONTINUUM_STATUS_SCRIPT" ]; then
		status=$(${TMUX_CONTINUUM_STATUS_SCRIPT})
	fi

	if [ -n "$status" ]; then
		echo "Continuum status: ${status}"
	fi

	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH" ]; then
		export TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH="${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT}"
	fi
	export TMUX_CONTINUUM_STATUS_SCRIPT="${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH}/${TMUX_CONTINUUM_STATUS_SCRIPT_RELPATH}"
}
