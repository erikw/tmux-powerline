__print_colored_content() {
	[ "${2:0:1}" = "#" ] && BGCOLOR="$2" || BGCOLOR="colour$2"
	[ "${3:0:1}" = "#" ] && FGCOLOR="$3" || FGCOLOR="colour$3"
	echo -n "#[fg=${FGCOLOR},bg=${BGCOLOR}]"
	echo -n "$1"
	echo -n "#[default]"
}
