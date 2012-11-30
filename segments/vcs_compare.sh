#!/usr/bin/env bash
# This checks if the current branch is ahead of
# or behind the remote branch with which it is tracked

# Source lib to get the function get_tmux_pwd
segment_path=$(dirname $0)
source "$segment_path/../lib.sh"

tmux_path=$(get_tmux_cwd)
cd "$tmux_path"

flat_symbol="⤚"
git_colour="colour5"
git_svn_colour="colour34"
svn_colour="colour220"
hg_colour="colour45"

parse_git_stats(){
	type git >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

    # check if git
    [[ -z $(git rev-parse --git-dir 2> /dev/null) ]] && return

    ahead=$( git rev-list origin..HEAD | wc -l)
    behind=$(git rev-list HEAD..origin | wc -l)

    # print out the information
    if [[ $behind -gt 0 ]] ; then
        local ret="↓ $behind"
    fi
    if [[ $ahead -gt 0 ]] ; then
        local ret="${ret}↑ $ahead"
    fi
    echo $ret
}
parse_hg_stats(){
	type svn >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
    # not yet implemented
}
parse_svn_stats(){
	type hg >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
    # not yet implemented
}

stats=""
if [ -n "${git_stats=$(parse_git_stats)}" ]; then
    stats="$git_stats"
elif [ -n "${svn_stats=$(parse_svn_stats)}" ]; then
    stats="$svn_stats"
elif [ -n "${hg_stats=$(parse_hg_stats)}" ]; then
    stats="$hg_stats"
fi

if [ -n "$stats" ]; then
    echo "${stats}"
fi
