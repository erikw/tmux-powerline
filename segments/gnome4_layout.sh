# shellcheck shell=bash
# Print the currently used keyboard layout
# Works with Gnome 40
# Set smaller update interval in .tmux.conf: 'set-option -g status-interval 1'
# Exit if platform is not linux as this script is dependant on Linux and Gnome DE

run_segment() {
	if ! shell_is_linux; then
		return 1
	fi

	cur_layout=$(gsettings get org.gnome.desktop.input-sources mru-sources | awk -F"'" '{print $4}')
	ecode=$?
	test $ecode -eq 0 || return $ecode

	echo "⌨  $cur_layout"
	return 0
}
