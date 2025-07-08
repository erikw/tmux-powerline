# shellcheck shell=bash
# Get the current path in the segment.
tp_get_tmux_cwd() {
	tmux display -p -F "#{pane_current_path}"
}
