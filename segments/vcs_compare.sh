# This checks if the current branch is ahead of
# or behind the remote branch with which it is tracked

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_COMPARE_AHEAD_SYMBOL="${TMUX_POWERLINE_SEG_VCS_COMPARE_AHEAD_SYMBOL:-↑}"
TMUX_POWERLINE_SEG_VCS_COMPARE_BEHIND_SYMBOL="${TMUX_POWERLINE_SEG_VCS_COMPARE_BEHIND_SYMBOL:-↓}"

generate_segmentrc() {
	read -d '' rccontents << EORC
# Symbol if local branch is behind.
# export TMUX_POWERLINE_SEG_VCS_COMPARE_AHEAD_SYMBOL="${TMUX_POWERLINE_SEG_VCS_COMPARE_AHEAD_SYMBOL}"
# Symbol if local branch is ahead.
# export TMUX_POWERLINE_SEG_VCS_COMPARE_BEHIND_SYMBOL="${TMUX_POWERLINE_SEG_VCS_COMPARE_BEHIND_SYMBOL}"
EORC
	echo "$rccontents"
}


run_segment() {
	__process_settings
	{ read vcs_type; read root_path; } < <(get_vcs_type_and_root_path)
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path"

	stats="$(__parse_${vcs_type}_stats)"

	if [ -n "$stats" ]; then
		echo "${stats}"
	fi
	return 0
}

__parse_git_stats() {
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
	# not yet implemented
	return
}

__parse_svn_stats() {
	# not yet implemented
	return
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_VCS_COMPARE_AHEAD_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VCS_COMPARE_AHEAD_SYMBOL="${TMUX_POWERLINE_SEG_VCS_COMPARE_AHEAD_SYMBOL}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VCS_COMPARE_BEHIND_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VCS_COMPARE_BEHIND_SYMBOL="${TMUX_POWERLINE_SEG_VCS_COMPARE_BEHIND_SYMBOL}"
	fi
}
