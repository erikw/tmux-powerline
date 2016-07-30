# This checks if the current branch is ahead of
# or behind the remote branch with which it is tracked

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"

flat_symbol="⤚"

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

	if [ -n "$stats" ]; then
		echo "${stats}"
	fi
	return 0
}

__parse_git_stats() {
	type git >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	# check if git
	[[ -z $(git rev-parse --git-dir 2> /dev/null) ]] && return

	symbolic_ref=$(git symbolic-ref -q HEAD)
	[[ -z "${symbolic_ref}" ]] && return

	tracking_branch=$(git for-each-ref --format='%(upstream:short)' ${symbolic_ref})

	# creates global variables $1 and $2 based on left vs. right tracking
	set -- $(git rev-list --left-right --count $tracking_branch...HEAD)

	behind=$1
	ahead=$2

	# print out the information
	if [[ $behind -gt 0 ]] ; then
		local ret="↓ $behind"
	fi
	if [[ $ahead -gt 0 ]] ; then
		local ret="${ret}↑ $ahead"
	fi
	echo "$ret"
}

__parse_hg_stats() {
	type hg >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
	# not yet implemented
}

__parse_svn_stats() {
	type svn >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
	# not yet implemented
}
