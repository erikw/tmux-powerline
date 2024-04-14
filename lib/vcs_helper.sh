# shellcheck shell=bash
# Source lib to get the function get_tmux_pwd
# shellcheck source=lib/tmux_adapter.sh
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"

get_vcs_type_and_root_path() {
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path" || return
	root_path=""
	git_root_path="$(__parse_git_root_path)"
	hg_root_path="$(__parse_hg_root_path)"
	svn_root_path="$(__parse_svn_root_path)"

	# Return path which is the longest and therefore closest path to the current working
	# dir. This is will be the root path of whatever vcs solution is used.
	echo -n "$(__get_closest_root_path "$git_root_path" "$hg_root_path" "$svn_root_path")"
}

__parse_git_root_path() {
	if ! type git >/dev/null 2>&1; then
		return
	fi

	if ! root_path=$(git rev-parse --show-toplevel 2>/dev/null); then
		return
	fi
	echo "${root_path}"
}

__parse_hg_root_path() {
	if ! type hg >/dev/null 2>&1; then
		return
	fi

	if ! root_path=$(hg root 2>/dev/null); then
		return
	fi
	echo "${root_path}"
}

__parse_svn_root_path() {
	if ! type svn >/dev/null 2>&1; then
		return
	fi

	if ! root_path=$(svn info --show-item wc-root 2>/dev/null); then
		return
	fi
	echo "${root_path}"
}

__get_closest_root_path() {
	VCS_TYPES=(git hg svn)
	path_id=0
	highest=0
	root_path=""
	counter=0
	for path in "$@"; do
		[ "${#path}" -gt "$highest" ] && highest="${#path}" && root_path="${path}" && path_id=$counter
		counter=$((counter + 1))
	done
	echo -en "${VCS_TYPES[${path_id}]}\n${root_path}"
}
