# Get the current path in the segment.
get_tmux_cwd() {
	local env_name=$(tmux display -p "#D" | tr -d %)
	# use papne_current_path, no need to set TMUXPWD
	local env_val=$(tmux display-message -p -F "#{pane_current_path}" -t"$env_name")
	# The version below is still quite new for tmux. Uncomment this in the future :-)
	#local env_val=$(tmux show-environment "$env_name" 2>&1)

	if [[ ! $env_val =~ "unknown variable" ]]; then
		local tmux_pwd=$(echo "$env_val" | sed 's/^.*=//')
		echo "$tmux_pwd"
	fi
}
