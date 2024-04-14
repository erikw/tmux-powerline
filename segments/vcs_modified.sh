# shellcheck shell=bash
# This checks if the current branch is ahead of
# or behind the remote branch with which it is tracked

# Source lib to get the function get_tmux_pwd
# shellcheck source=lib/tmux_adapter.sh
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
# shellcheck source=lib/vcs_helper.sh
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL:-± }"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Symbol for count of modified vcs files.
# export TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL}"
EORC
	echo "$rccontents"
}

run_segment() {
	{
		read -r vcs_type
		read -r vcs_rootpath
	} < <(get_vcs_type_and_root_path)
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path" || return

	stats=$(__parse_"${vcs_type}"_stats "$vcs_rootpath")
	# Ensure spaces are removed (e.g. from macOS 'wc' command)
	stats=${stats//[[:space:]]/}

	if [[ -n "$stats" && $stats -gt 0 ]]; then
		echo "${TMUX_POWERLINE_SEG_VCS_MODIFIED_SYMBOL}${stats}"
	fi
}

__parse_git_stats() {
	local rootpath
	local modified

	rootpath=$1

	# check if git
	[[ -z $(git rev-parse --git-dir 2>/dev/null) ]] && return

	# return the number of modified but not staged items
	modified=$(git ls-files --modified "$rootpath" | wc -l)
	echo "$modified"
}
__parse_hg_stats() {
	local modified

	modified=$(hg status -m | wc -l)
	echo "${modified}"
}
__parse_svn_stats() {
	local svn_info
	local svn_wcroot
	local svn_st
	local modified
	local conflicted

	svn_info=$(svn info 2>/dev/null)
	if [ -z "${svn_info}" ]; then
		return
	fi

	svn_wcroot=$(echo "${svn_info}" | sed -ne 's#^Working Copy Root Path: ##p')
	svn_st=$(cd "${svn_wcroot}" && svn st)
	modified=$(echo "${svn_st}" | grep -E '^M' -c)
	conflicted=$(echo "${svn_st}" | grep -E '^!?\s*C' -c)

	#print
	if [[ $conflicted -gt 0 ]]; then
		local ret="ϟ ${conflicted}"
	fi
	if [[ $modified -gt 0 ]]; then
		local ret="${modified} ${ret}"
	fi
	echo "${ret}"
}
