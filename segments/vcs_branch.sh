# shellcheck shell=bash
# Prints current branch in a VCS directory if it could be detected.

# Source lib to get the function get_tmux_pwd
# shellcheck source=lib/tmux_adapter.sh
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
# shellcheck source=lib/vcs_helper.sh
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN="${TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN:-24}"
TMUX_POWERLINE_SEG_VCS_BRANCH_TRUNCATE_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_TRUNCATE_SYMBOL:-…}"
TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL:-}"
TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL:-$TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR:-5}"
TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL:-$TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR:-45}"
TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL:-$TMUX_POWERLINE_SEG_VCS_BRANCH_DEFAULT_SYMBOL}"
TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR:-220}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Max length of the branch name.
export TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN="${TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN_DEFAULT}"
# Symbol when branch length exceeds max length
# export TMUX_POWERLINE_SEG_VCS_BRANCH_TRUNCATE_SYMBOL="${TMUX_POWERLINE_SEG_VCS_BRANCH_TRUNCATE_SYMBOL}"
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
	local branch

	{
		read -r vcs_type
		read -r vcs_rootpath
	} < <(get_vcs_type_and_root_path)
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path" || return
	branch=$(__parse_"${vcs_type}"_branch "$vcs_rootpath")

	if [ -n "$branch" ]; then
		echo "${branch}"
	fi
	return 0
}

# Show git banch.
__parse_git_branch() {
	local branch

	# Quit if this is not a Git repo.
	if ! branch=$(git symbolic-ref HEAD 2>/dev/null); then
		return
	fi
	if [[ -z $branch ]]; then
		# attempt to get short-sha-name
		if ! branch=":$(git rev-parse --short HEAD 2>/dev/null)"; then
			return
		fi
	fi

	# Clean off unnecessary information.
	branch=${branch#refs\/heads\/}
	branch=$(__truncate_branch_name "$branch")

	echo -n "#[fg=colour${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_VCS_BRANCH_GIT_SYMBOL} #[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${branch}"
}

# Show SVN branch.
__parse_svn_branch() {
	local rootpath
	local svn_info
	local branch

	rootpath="$1"

	svn_info=$(svn info "$rootpath" 2>/dev/null)
	if [ -z "${svn_info}" ]; then
		return
	fi

	while read -r line; do
		[[ "$line" =~ ^URL: ]] && branch=${line##*/}
	done < <(echo "$svn_info")

	[ -z "$branch" ] && return

	branch=$(__truncate_branch_name "$branch")
	echo "#[fg=colour${TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_VCS_BRANCH_SVN_SYMBOL} #[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${branch}"
}

# Show hg/mercurial branch.
__parse_hg_branch() {
	local branch

	if ! summary=$(hg summary); then
		return
	fi

	while read -r line; do
		[[ "$line" =~ ^branch: ]] && branch=${line#*: } && break
	done < <(echo "$summary")

	[ -z "$branch" ] && return

	branch=$(__truncate_branch_name "$branch")
	echo "#[fg=colour${TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_VCS_BRANCH_HG_SYMBOL} #[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${branch}"
}

# Ensure max branch length
__truncate_branch_name() {
	local trunc_symbol
	local branch

	trunc_symbol="$TMUX_POWERLINE_SEG_VCS_BRANCH_TRUNCATE_SYMBOL"
	branch="$1"

	# ensure branch name length is less than defined max lenght
	if [ "${#branch}" -gt "$TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN" ]; then
		branch=${branch:0:$((TMUX_POWERLINE_SEG_VCS_BRANCH_MAX_LEN - ${#trunc_symbol}))}
		# append trunc_symbol
		branch="${branch}${trunc_symbol}"
	fi

	echo -n "$branch"
}
