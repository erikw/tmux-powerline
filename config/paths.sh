# Paths

export TMUX_POWERLINE_DIR_LIB="$TMUX_POWERLINE_DIR_HOME/lib"
export TMUX_POWERLINE_DIR_SEGMENTS="$TMUX_POWERLINE_DIR_HOME/segments"
export TMUX_POWERLINE_DIR_TEMPORARY="/tmp/tmux-powerline_${USER}"
export TMUX_POWERLINE_DIR_THEMES="$TMUX_POWERLINE_DIR_HOME/themes"
if [ -z "$TMUX_POWERLINE_RCFILE" ]; then
	if [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/config.sh" ]; then
		export TMUX_POWERLINE_RCFILE="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/config.sh"
	else
		export TMUX_POWERLINE_RCFILE="$HOME/.tmux-powerlinerc"
	fi
fi
export TMUX_POWERLINE_RCFILE_DEFAULT="${TMUX_POWERLINE_RCFILE}.default"

if [ ! -d "$TMUX_POWERLINE_DIR_TEMPORARY" ]; then
	mkdir "$TMUX_POWERLINE_DIR_TEMPORARY"
fi
