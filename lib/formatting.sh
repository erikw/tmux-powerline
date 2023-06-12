
__print_colored_content() {
	bgcolor=$(__normalize_color "$2")
	fgcolor=$(__normalize_color "$3")

	echo -n "#[fg=${fgcolor},bg=${bgcolor}]"
	echo -n "$1"
	echo -n "#[default]"
}

