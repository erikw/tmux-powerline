# Get the current path in the segment.
get_tmux_cwd() {
	local env_name=$(tmux display -p "TMUXPWD_#D" | tr -d %)
	local env_val=$(tmux show-environment | grep --color=never "$env_name")
	# The version below is still quite new for tmux. Uncomment this in the future :-)
	#local env_val=$(tmux show-environment "$env_name" 2>&1)

	if [[ ! $env_val =~ "unknown variable" ]]; then
		local tmux_pwd=$(echo "$env_val" | sed 's/^.*=//')
		echo "$tmux_pwd"
	fi
}
