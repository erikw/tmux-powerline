# shellcheck shell=bash
# Source lib to get the function __get_vcs_root_path_and_vcs
# shellcheck source=lib/vcs_helper.sh
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE="${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE:-name}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Display mode for vcs_rootpath.
# Example: (name: folder name only; path: full path, w/o expansion; user_path: full path, w/ tilde expansion)
# export TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE="${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE}"
EORC
	echo "$rccontents"
}

run_segment() {
	# get root_path
	{
		read -r _unused
		read -r root_path
	} < <(get_vcs_type_and_root_path)

	if [ -n "$root_path" ]; then
		if [ "${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE}" = "user_path" ]; then
			root_path=${root_path/#$HOME/\~}
		elif [ "${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE}" = "path" ]; then
			# no-op
			true
		# name, default, fallback for misconfiguration
		elif [ "${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE}" = "name" ] || :; then
			root_path=${root_path/#$HOME/\~}
			root_path=${root_path/*\//}
		fi
		echo -n "#[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${root_path}"
	fi

	return 0
}
