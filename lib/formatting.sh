__normalize_color() {
	input="$1"
	result

	case "$input" in
			[0-9]|[0-9][0-9]|[0-9][0-9][0-9]) # Convert 1 to 3 digit colours to 'colour[code]'
					result="colour$input"
					;;
			*) # otherwise return whatever is passed
					result=$input
					;;
	esac

	echo -n "$result"
}

__print_colored_content() {
	bgcolor=$(__normalize_color "$2")
	fgcolor=$(__normalize_color "$3")

	echo -n "#[fg=${fgcolor},bg=${bgcolor}]"
	echo -n "$1"
	echo -n "#[default]"
}

