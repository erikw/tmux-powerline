#/usr/bin/env bash
# Prints current branch in a VCS directory if it could be detected.

# Source lib to get the function get_tmux_pwd
segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

tmux_path=$(get_tmux_cwd)
cd "$tmux_path"

branch_symbol="⭠"
git_colour="colour5"
git_svn_colour="colour34"
svn_colour="colour220"

# Show git banch.
parse_git_branch() {
	type git 2>&1 > /dev/null
	if [ "$?" -ne 0 ]; then
		return
	fi

	#git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \[\1\]/'

	# Quit if this is not a Git repo.
	branches=$(git branch 2>/dev/null)
	if [ "$?" -ne 0 ]; then
		return
	fi

	local branch=$(echo "$branches" | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

	echo "$branches" | grep --color=never "remotes/git-svn" &>/dev/null
	is_gitsvn=$([ "$?" -eq 0 ] && echo 1 || echo 0)

	echo  -n "#[fg="
	if [ "$is_gitsvn" -eq "0" ]; then
		echo -n "$git_colour"
	else
		echo -n "$git_svn_colour"
	fi
	# TODO pass colour arguments as paramters/globals to segments?
	echo "]${branch_symbol} #[fg=colour42]${branch}"
}

# Show SVN branch.
parse_svn_branch() {
	if [ ! -d ".svn/" ]; then
		return
	fi

	type svn 2>&1 > /dev/null
	if [ "$?" -ne 0 ]; then
		return
	fi

	local svn_root=$(svn info 2>/dev/null | sed -ne 's#^Repository Root: ##p')
	local svn_url=$(svn info 2>/dev/null | sed -ne 's#^URL: ##p')

	local branch=$(echo $svn_url | sed -e 's#^'"${svn_root}"'##g' | egrep --color=never -o '(tags|branches)/[^/]+|trunk' | egrep --color=never -o '[^/]+$' | awk '{print $1}')
	echo  "#[fg=${svn_colour}]${branch_symbol} #[fg=colour42]${branch}"
}

branch=""
if [ -n "${git_branch=$(parse_git_branch)}" ]; then
	branch="$git_branch"
elif [ -n "${svn_branch=$(parse_svn_branch)}" ]; then
	branch="$svn_branch"
fi

if [ -n "$branch" ]; then
	echo "${branch}"
fi
