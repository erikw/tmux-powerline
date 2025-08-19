# shellcheck shell=bash
# Adapter for tmux-continuum (https://github.com/tmux-plugins/tmux-continuum) to auto save state with tmux-resurrect.

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

#TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT:-short}"
TMUX_CONTINUUM_PATH="${TMUX_PLUGIN_MANAGER_PATH}/tmux-continuum"
TMUX_CONTINUUM_SAVE_SCRIPT="${TMUX_CONTINUUM_PATH}/scripts/continuum_save.sh"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Use short, long or custom format for the hostname. Can be {"short", "long", "custom"}.
export TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="${TMUX_POWERLINE_SEG_HOSTNAME_FORMAT}"
# Custom name to be used when format is "custom"
export TMUX_POWERLINE_SEG_HOSTNAME_CUSTOM="${TMUX_POWERLINE_SEG_HOSTNAME_CUSTOM}"
EORC
	echo "$rccontents"
}

run_segment() {
	if [ -x "$TMUX_CONTINUUM_SAVE_SCRIPT" ]; then
		$TMUX_CONTINUUM_SAVE_SCRIPT
	fi
	return 0
}
