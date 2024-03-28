# This checks if the current branch is ahead of
# or behind the remote branch with which it is tracked

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL:-±}"

generate_segmentrc() {
	read -d '' rccontents << EORC
# Symbol for count of modified vcs files.
# export TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL}"
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
		echo "${TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL} ${stats}"
	fi
}

__parse_git_stats(){
	# check if git
	[[ -z $(git rev-parse --git-dir 2> /dev/null) ]] && return

	# return the number of modified but not staged items
	modified=$(git ls-files --modified `git rev-parse --show-cdup` | wc -l)
	echo $modified
}
__parse_hg_stats(){
	local modified=$(hg status -m | wc -l)
	if [ -z "${modified}" ]; then
		return
	fi
	echo ${modified}
}
__parse_svn_stats() {
	local svn_info=$(svn info 2>/dev/null)
	if [ -z "${svn_info}" ]; then
		return
	fi

	local svn_wcroot=$(echo "${svn_info}" | sed -ne 's#^Working Copy Root Path: ##p')
	local svn_st=$(cd "${svn_wcroot}"; svn st)
	local modified=$(echo "${svn_st}" | grep -E '^M' | wc -l)
	local conflicted=$(echo "${svn_st}" | grep -E '^!?\s*C' | wc -l)

	#print
	if [[ $conflicted -gt 0 ]] ; then
		local ret="ϟ ${conflicted}"
	fi
	if [[ $modified -gt 0 ]] ; then
		local ret="${modified} ${ret}"
	fi
	echo "${ret}"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL}"
	fi
}
