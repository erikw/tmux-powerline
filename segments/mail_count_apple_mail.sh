# Print mail count for Apple Mail.
run_segment() {
	mailcount=$(${TMUX_POWERLINE_DIR_SEGMENTS}/mail_count_apple_mail.script)
	if [ -n "$mailcount" ]; then
		echo "mailcount"
	fi
	return 0
}
