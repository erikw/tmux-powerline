#!/usr/bin/env bash
# Prints current branch in a VCS directory if it could be detected.

# Source lib to get the function get_tmux_pwd
segment_path=$(dirname $0)
source "$segment_path/../lib/tmux_adapter.sh"

tmux_path=$(get_tmux_cwd)
cd "$tmux_path"

branch_symbol="⭠"
git_colour="5"
svn_colour="220"
hg_colour="45"

# Show git banch.
parse_git_branch() {
	type git >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	#git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \[\1\]/'

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
    branch=${branch##*/}

	echo  -n "#[fg=colour${git_colour}]${branch_symbol} #[fg=colour${TMUX_POWERLINE_CUR_SEGMENT_FG}]${branch}"
}

# Show SVN branch.
parse_svn_branch() {
	type svn >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	if [ ! -d ".svn/" ]; then
		return
	fi


	local svn_root=$(svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p')
	local svn_url=$(svn info 2>/dev/null | sed -ne 's#^URL: ##p')

	local branch=$(echo $svn_url | sed -e 's#^'"${svn_root}"'##g' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$' | awk '{print $1}')
	echo  "#[fg=colour${svn_colour}]${branch_symbol} #[fg=colour${TMUX_POWERLINE_CUR_SEGMENT_FG}]${branch}"
}

parse_hg_branch() {
	type hg >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	summary=$(hg summary)
	if [ "$?" -ne 0 ]; then
		return
	fi

	local branch=$(echo "$summary" | grep 'branch:' | cut -d ' ' -f2)
	echo  "#[fg=colour${hg_colour}]${branch_symbol} #[fg=colour${TMUX_POWERLINE_CUR_SEGMENT_FG}]${branch}"
}

branch=""
if [ -n "${git_branch=$(parse_git_branch)}" ]; then
	branch="$git_branch"
elif [ -n "${svn_branch=$(parse_svn_branch)}" ]; then
	branch="$svn_branch"
elif [ -n "${hg_branch=$(parse_hg_branch)}" ]; then
	branch="$hg_branch"
fi

if [ -n "$branch" ]; then
	echo "${branch}"
fi
