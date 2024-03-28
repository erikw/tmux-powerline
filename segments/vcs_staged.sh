# This checks if the current branch is ahead of
# or behind the remote branch with which it is tracked

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL:-⊕}"

generate_segmentrc() {
	read -d '' rccontents << EORC
# Symbol for count of staged vcs files.
# export TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL}"
EORC
	echo "$rccontents"
}


run_segment() {
	__process_settings
	{ read vcs_type; read root_path; } < <(get_vcs_type_and_root_path)
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path"

	stats="$(__parse_${vcs_type}_stats)"

	if [[ -n "$stats" && $stats -gt 0 ]]; then
		stats=$(echo $stats | sed -e "s/^[ \t]*//")
		echo "${TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL} ${stats}"
	fi
	return 0
}


__parse_git_stats(){
	# Check if git.
	[[ -z $(git rev-parse --git-dir 2> /dev/null) ]] && return

	# Return the number of staged items.
	staged=$(git diff --staged --name-status | wc -l)
	echo "$staged"
}

__parse_hg_stats(){
	# not yet implemented
	return
}

__parse_svn_stats(){
	# not yet implemented
	return
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL}"
	fi
}
