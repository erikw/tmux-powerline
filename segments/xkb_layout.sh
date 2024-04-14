# shellcheck shell=bash
# Print the currently used keyboard layout
# This depends on a specifically developed program which prints the group id of
# the currently used layout.
# I developed the simple program myself with some guidance as I was unable to
# find anything already developed.
# Some people might suggest:
# $ setxkbmod -query -v | awk -F "+" '{print $2}'
# this will only work if you have set up XKB with a single layout which is true
# for some.

# This script will print the correct layout even if layout is set per window.
# Exit if platform is not linux as this script is dependant on X11

TMUX_POWERLINE_SEG_XKB_LAYOUT_ICON="${TMUX_POWERLINE_SEG_XKB_LAYOUT_ICON:-⌨ }"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Keyboard icon
export TMUX_POWERLINE_SEG_XKB_LAYOUT_ICON="${TMUX_POWERLINE_SEG_XKB_LAYOUT_ICON}"
EORC
	echo "$rccontents"
}

run_segment() {
	if ! shell_is_linux; then
		return 1
	fi

	cd "$TMUX_POWERLINE_DIR_SEGMENTS" || return
	if [ ! -x "xkb_layout" ]; then
		make clean xkb_layout &>/dev/null
	fi

	if [ -x ./xkb_layout ]; then
		cur_layout_nbr=$(./xkb_layout)
		IFS=$',' read -r -a layouts < <(setxkbmap -query | grep layout | sed 's/layout:\s\+//g')
		cur_layout="${layouts[$cur_layout_nbr]}"
		echo "$TMUX_POWERLINE_SEG_XKB_LAYOUT_ICON $cur_layout"
	else
		return 1
	fi
}
