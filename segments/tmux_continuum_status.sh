# shellcheck shell=bash
# Adapter for tmux-continuum (https://github.com/tmux-plugins/tmux-continuum) to show save state.
# This replaces manually putting "#{continuum_status}" in your status-(left|right) as instructed in the continuum README.md.
# NOTE for tmux-continuum to actually save the state, you also need to enable the segment tmux_continuum_save.sh

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

if [[ -n "$TMUX_PLUGIN_MANAGER_PATH" ]]; then
	TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT="${TMUX_PLUGIN_MANAGER_PATH}/tmux-continuum"
elif [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/tmux" ]]; then
	TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tmux-continuum"
else
	TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT="${HOME}/.tmux/plugins/tmux-continuum"
fi
TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PREFIX_DEFAULT="Continuum status: "

TMUX_CONTINUUM_STATUS_SCRIPT_RELPATH="scripts/continuum_status.sh"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Path to the tmux-continuum git repo.
export TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH="${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT}"
# Message to perfix the status indication with.
export TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PREFIX="$TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PREFIX_DEFAULT"
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
		echo "${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PREFIX}${status}"
	fi

	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH" ]; then
		export TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH="${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT}"
	fi
	export TMUX_CONTINUUM_STATUS_SCRIPT="${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH}/${TMUX_CONTINUUM_STATUS_SCRIPT_RELPATH}"

	if [ -z "$TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PREFIX" ]; then
		export TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PREFIX="${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PREFIX_DEFAULT}"
	fi
}
