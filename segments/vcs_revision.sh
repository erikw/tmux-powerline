# This prints the vcs revision in the working directory
# currently only used in SVN

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

run_segment() {
	{ read vcs_type; read root_path; } < <(get_vcs_type_and_root_path)
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path"

	stats="$(__parse_${vcs_type}_stats)"

	if [[ -n "$stats" ]]; then
		echo "${stats}"
	fi
}

__parse_git_stats() {
	local git_rev=$(git rev-parse --short HEAD)
	if [ -z "$git_rev" ]; then
		return
	fi

	echo "${git_rev}"
}

__parse_hg_stats(){
	local hg_rev=$(hg id -i)
	if [ -z "$hg_rev" ]; then
		return
	fi
	echo "${hg_rev}"
}
__parse_svn_stats(){
	local svn_info=$(svn info 2>/dev/null)
	if [ -z "${svn_info}" ]; then
		return
	fi

	local svn_rev=$(echo "${svn_info}" | sed -ne 's#^Revision: ##p')

	echo "r${svn_rev}"
}
