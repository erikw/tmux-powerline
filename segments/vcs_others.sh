# This checks if the current branch is ahead of or behind the remote branch with which it is tracked.

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL="${TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL:-⋯}"

generate_segmentrc() {
	read -d '' rccontents << EORC
# Symbol for count of untracked vcs files.
# export TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL="${TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL}"
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
		echo "${TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL} ${stats}"
	fi
	return 0
}

__parse_git_stats(){
	# check if git
	[[ -z $(git rev-parse --git-dir 2> /dev/null) ]] && return

	# return the number of untracked items
	other=$(git ls-files --others --exclude-standard `git rev-parse --show-cdup` | wc -l)
	echo $other
}
__parse_hg_stats(){
	other=$(hg status -u | wc -l)
	if [ -z "$other" ]; then
		return
	fi
	echo $other
}
__parse_svn_stats(){
	# not yet implemented
	return
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL="${TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL}"
	fi
}
