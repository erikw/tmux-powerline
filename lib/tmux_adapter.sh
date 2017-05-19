# Get the current path in the segment.
MIN_MAJOR_VERSION="2"
MIN_MINOR_VERSION="1"
TMUX_VERSION="$(tmux -V)"

if [[ "${TMUX_VERSION}" =~ .*([[:digit:]]+)\.([[:digit:]]+) ]]; then
	TMUX_MAJOR_VERSION="${BASH_REMATCH[1]}"
	TMUX_MINOR_VERSION="${BASH_REMATCH[2]}"
	if [[ ("${TMUX_MAJOR_VERSION}" -gt "${MIN_MAJOR_VERSION}") || (("${TMUX_MAJOR_VERSION}" -eq "${MIN_MAJOR_VERSION}") && ("${TMUX_MINOR_VERSION}" -ge "${MIN_MINOR_VERSION}")) ]]; then
		get_tmux_cwd() {
			tmux display -p -F "#{pane_current_path}"
		}
	fi
fi

if [[ -z "$(type -t get_tmux_cwd)" ]]; then
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
fi

unset MIN_MAJOR_VERSION
unset MIN_MINOR_VERSION
unset TMUX_VERSION
