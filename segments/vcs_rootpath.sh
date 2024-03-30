# Source lib to get the function __get_vcs_root_path_and_vcs
source "${TMUX_POWERLINE_DIR_LIB}/vcs_helper.sh"

TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE="${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE:-1}"

generate_segmentrc() {
	read -d '' rccontents << EORC
# Display mode for vcs_rootpath.
# Example: (1: folder name only; 2: full path, w/o expansion; 3: full path, w/ tilde expansion)
# export TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE="${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE}"
EORC
	echo "$rccontents"
}


run_segment() {
	__process_settings
	# get root_path
	{ read; read root_path; } <	<(get_vcs_type_and_root_path)

	if [ -n "$root_path" ]; then
		if [ "${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE}" -eq 1 ]; then
			root_path="${root_path/#$HOME/\~}"
			root_path="${root_path/*\//}"
		elif [ "${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE}" -eq 2 ]; then
			root_path="${root_path/#$HOME/\~}"
		elif [ "${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE}" -eq 3 ]; then
			root_path="${root_path}"
		fi
		echo -n "#[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${root_path}"
	fi

	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE" ]; then
		export TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE="${TMUX_POWERLINE_SEG_VCS_ROOTPATH_MODE}"
	fi
}
