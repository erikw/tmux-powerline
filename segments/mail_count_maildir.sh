# Return the number of new mails in a maildir.

TMUX_POWERLINE_SEG_MAILCOUNT_MAILDIR_INBOX_DEFAULT="$HOME/.mail/inbox/new"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# Path to the maildir to check.
export TMUX_POWERLINE_SEG_MAILCOUNT_MAILDIR_INBOX="${TMUX_POWERLINE_SEG_MAILCOUNT_MAILDIR_INBOX_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	cd "$(dirname $0)"

	if [ ! -d "$TMUX_POWERLINE_SEG_MAILCOUNT_MAILDIR_INBOX" ]; then
		return 1
	fi

	nbr_new=$(ls "$TMUX_POWERLINE_SEG_MAILCOUNT_MAILDIR_INBOX" | wc -l)

	# Fix for mac, otherwise whitespace is left in output
	if [ "$PLATFORM" == "mac" ]; then
		nbr_new=$(echo "$nbr_new" | sed -e "s/^[ \t]*//")
	fi

	if [ "$nbr_new" -gt "0" ]; then
		echo "✉ ${nbr_new}"
	fi

	return 0;
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_MAILCOUNT_MAILDIR_INBOX" ]; then
		export TMUX_POWERLINE_SEG_MAILCOUNT_MAILDIR_INBOX="${TMUX_POWERLINE_SEG_MAILCOUNT_MAILDIR_INBOX_DEFAULT}"
	fi
}
