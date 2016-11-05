# This checks if the current branch is ahead of or behind the remote branch with which it is tracked.

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"

other_symbol="⋯ "

run_segment() {
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path"
	stats=""
	if [ -n "${git_stats=$(__parse_git_stats)}" ]; then
		stats="$git_stats"
	elif [ -n "${svn_stats=$(__parse_svn_stats)}" ]; then
		stats="$svn_stats"
	elif [ -n "${hg_stats=$(__parse_hg_stats)}" ]; then
		stats="$hg_stats"
	fi
	if [[ -n "$stats" && $stats -gt 0 ]]; then
		echo "${other_symbol}${stats}"
	fi
	return 0
}

__parse_git_stats(){
	type git >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	# check if git
	[[ -z $(git rev-parse --git-dir 2> /dev/null) ]] && return

	# return the number of untracked items
	other=$(git ls-files --others --exclude-standard `git rev-parse --show-cdup` | wc -l)
	echo $other
}
__parse_hg_stats(){
	type svn >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
	# not yet implemented
}
__parse_svn_stats(){
	type hg >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
	# not yet implemented
}
