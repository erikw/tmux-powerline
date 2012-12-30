# This prints the vcs revision in the working directory
# currently only used in SVN

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"

run_segment() {
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path"

	stats=""
	if [[ -n "${svn_stats=$(__parse_svn_stats)}" ]]; then
		stats="$svn_stats"
	elif [[ -n "${hg_stats=$(__parse_hg_stats)}" ]]; then
		stats="$hg_stats"
	fi
	if [[ -n "$stats" ]]; then
		echo "${stats}"
	fi
}

__parse_hg_stats(){
	type hg >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
	# not yet implemented
}
__parse_svn_stats(){
	type svn >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	local svn_info=$(svn info 2>/dev/null)
	if [ -z "${svn_info}" ]; then
		return
	fi

	local svn_ref=$(echo "${svn_info}" | sed -ne 's#^Revision: ##p')

	echo "r${svn_ref}"
}
