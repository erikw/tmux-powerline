# shellcheck shell=bash
# Adapter for tmux-continuum (https://github.com/tmux-plugins/tmux-continuum) to auto save state with tmux-resurrect.
# If you want to see the status of tmux-continuum, please enable the segment tmux_continuum_status.sh.

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

if [[ -n "$TMUX_PLUGIN_MANAGER_PATH" ]]; then
	TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT="${TMUX_PLUGIN_MANAGER_PATH}/tmux-continuum"
elif [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/tmux" ]]; then
	TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tmux-continuum"
else
	TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT="${HOME}/.tmux/plugins/tmux-continuum"
fi

TMUX_CONTINUUM_SAVE_SCRIPT_RELPATH="scripts/continuum_save.sh"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Path to the tmux-continuum git repo.
export TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH="${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	if [ -x "$TMUX_CONTINUUM_SAVE_SCRIPT" ]; then
		$TMUX_CONTINUUM_SAVE_SCRIPT
	fi
	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH" ]; then
		export TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH="${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH_DEFAULT}"
	fi
	export TMUX_CONTINUUM_SAVE_SCRIPT="${TMUX_POWERLINE_SEG_TMUX_CONTINUUM_PATH}/${TMUX_CONTINUUM_SAVE_SCRIPT_RELPATH}"
}
