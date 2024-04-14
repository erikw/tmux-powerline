# shellcheck shell=bash
# This checks if the current branch is ahead of
# or behind the remote branch with which it is tracked

# Source lib to get the function get_tmux_pwd
# shellcheck source=lib/tmux_adapter.sh
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"
# shellcheck source=lib/vcs_helper.sh
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL:-⊕ }"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Symbol for count of staged vcs files.
# export TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL="${TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL}"
EORC
	echo "$rccontents"
}

run_segment() {
	{
		read -r vcs_type
		read -r _unused
	} < <(get_vcs_type_and_root_path)
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path" || return

	stats=$(__parse_"${vcs_type}"_stats)

	if [[ -n "$stats" && $stats -gt 0 ]]; then
		# multiline string would need while read, which is less efficient than sed
		# shellcheck disable=SC2001
		stats=$(echo "$stats" | sed -e "s#^[ \t]*##")
		echo "${TMUX_POWERLINE_SEG_VCS_STAGED_SYMBOL}${stats}"
	fi
	return 0
}

__parse_git_stats() {
	# Check if git.
	[[ -z $(git rev-parse --git-dir 2>/dev/null) ]] && return

	# Return the number of staged items.
	staged=$(git diff --staged --name-status | wc -l)
	echo "$staged"
}

__parse_hg_stats() {
	# not yet implemented
	return
}

__parse_svn_stats() {
	# not yet implemented
	return
}
