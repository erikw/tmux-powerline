# shellcheck shell=bash
# This checks if we have untracked/new files in vcs

# Source lib to get the function get_tmux_pwd
# shellcheck source=lib/tmux_adapter.sh
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
# shellcheck source=lib/vcs_helper.sh
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL="${TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL:-⋯}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Symbol for count of untracked vcs files.
# export TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL="${TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL}"
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
		echo "${TMUX_POWERLINE_SEG_VCS_OTHERS_SYMBOL} ${stats}"
	fi
	return 0
}

__parse_git_stats() {
	local rootpath

	rootpath=$1

	# check if git
	[[ -z $(git rev-parse --git-dir 2>/dev/null) ]] && return

	# return the number of untracked items
	other=$(git ls-files --others --exclude-standard "$rootpath" | wc -l)
	echo "$other"
}

__parse_hg_stats() {
	other=$(hg status -u | wc -l)
	if [ -z "$other" ]; then
		return
	fi
	echo "$other"
}

__parse_svn_stats() {
	if ! svn_stats=$(svn stat 2>/dev/null); then
		return
	fi
	[ -z "$svn_stats" ] && return

	other=$(echo "$svn_stats" | grep -E '^\?' -c)
	echo "$other"
}
