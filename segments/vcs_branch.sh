# Prints current branch in a VCS directory if it could be detected.

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN_DEFAULT=24
TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL:-}"
TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR:-5}"
TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR:-45}"
TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR:-220}"


generate_segmentrc() {
	read -d '' rccontents  << EORC
# Max length of the branch name.
export TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN="${TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN_DEFAULT}"
# Default branch symbol
export TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
# Branch symbol for git repositories
# export TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL="\${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
# Branch symbol for hg/mercurial repositories
# export TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL="\${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
# Branch symbol for SVN repositories
# export TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL="\${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
# Branch symbol colour for git repositories
export TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR}"
# Branch symbol colour for hg/mercurial repositories
export TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR}"
# Branch symbol colour for SVN repositories
export TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR}"
EORC
	echo "$rccontents"
}


run_segment() {
	__process_settings
	{ read vcs_type; read root_path; } < <(get_vcs_type_and_root_path)
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path"
	branch="$(__parse_${vcs_type}_branch)"

	if [ -n "$branch" ]; then
		echo "${branch}"
	fi
	return 0
}


# Show git banch.
__parse_git_branch() {
	# Quit if this is not a Git repo.
	branch=$(git symbolic-ref HEAD 2> /dev/null)
	if [[ -z $branch ]] ; then
		# attempt to get short-sha-name
		branch=":$(git rev-parse --short HEAD 2> /dev/null)"
	fi
	if [ "$?" -ne 0 ]; then
		# this must not be a git repo
		return
	fi

	# Clean off unnecessary information.
	branch=${branch#refs\/heads\/}
	branch=$(__truncate_branch_name $branch)

	echo -n "#[fg=colour${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL} #[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${branch}"
}

# Show SVN branch.
__parse_svn_branch() {
	local svn_info=$(svn info 2>/dev/null)
	if [ -z "${svn_info}" ]; then
		return
	fi


	local svn_root=$(echo "${svn_info}" | sed -ne 's#^Repository Root: ##p')
	local svn_url=$(echo "${svn_info}" | sed -ne 's#^URL: ##p')

	local branch=$(echo "${svn_url}" | grep -E -o '[^/]+$')
	branch=$(__truncate_branch_name $branch)
	echo "#[fg=colour${TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL} #[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${branch}"
}

__parse_hg_branch() {
	summary=$(hg summary)
	if [ "$?" -ne 0 ]; then
		return
	fi

	local branch=$(echo "$summary" | grep 'branch:' | cut -d ' ' -f2)
	branch=$(__truncate_branch_name $branch)
	echo "#[fg=colour${TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL} #[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${branch}"
}


__truncate_branch_name() {
	trunc_symbol="…"
	branch=$(echo $1 | sed "s/\(.\{$TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN\}\).*/\1$trunc_symbol/")
	echo -n $branch
}


__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN" ]; then
		export TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN="${TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR" ]; then
		export TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR" ]; then
		export TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR" ]; then
		export TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR}"
	fi
}
