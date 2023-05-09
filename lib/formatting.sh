__print_colored_content() {
	bgcolor="$2"
	fgcolor="$3"
	if [[ $bgcolor == "default" ]] ; then
		  BGCOLOR=$bgcolor
	else
	[ "${bgcolor:0:1}" = "#" ] && BGCOLOR="$bgcolor" || BGCOLOR="colour$bgcolor"
	fi

	if [[ "$fgcolor" == "default" ]] ; then
		FGCOLOR=$fgcolor
	else
	[ "${fgcolor:0:1}" = "#" ] && FGCOLOR="$fgcolor" || FGCOLOR="colour$fgcolor"
	fi

	 echo -n "#[fg=${FGCOLOR},bg=${BGCOLOR}]"
	 echo -n "$1"
	 echo -n "#[default]"
}
