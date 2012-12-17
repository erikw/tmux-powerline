# Echo the number of new mails in an mbox
# vi: sw=8 ts=8 noet

TMUX_POWERLINE_SEG_MAILCOUNT_MBOX_INBOX_DEFAULT="${MAIL}"

generate_segmentrc() {
	read -d '' rccontents  << EORC
	# Path to the mbox to check.
	export TMUX_POWERLINE_SEG_MAILCOUNT_MBOX_INBOX="${TMUX_POWERLINE_SEG_MAILCOUNT_MBOX_INBOX_DEFAULT}"
EORC
echo "${rccontents}"
}

run_segment() {
	__process_settings
	cd "$(dirname ${0})"

	if [ ! -f "${TMUX_POWERLINE_SEG_MAILCOUNT_MBOX_INBOX}" ]; then
		return 1
	fi

	# This matches the From_ line (see man 5 mbox) e.g.
	# From noreply@github.com  Sun Dec	2 03:52:25 2012
	# See https://github.com/erikw/tmux-powerline/pull/91#issuecomment-10926053 for discussion.
	nbr_new=$(grep -c '^From [^[:space:]]\+  ... ... .. ..:..:.. ....$' ${TMUX_POWERLINE_SEG_MAILCOUNT_MBOX_INBOX})

	if [ "${nbr_new}" -gt "0" ]; then
		echo "✉ ${nbr_new}"
	fi

	return 0;
}

__process_settings() {
	if [ -z "${TMUX_POWERLINE_SEG_MAILCOUNT_MBOX_INBOX}" ]; then
		export TMUX_POWERLINE_SEG_MAILCOUNT_MBOX_INBOX="${TMUX_POWERLINE_SEG_MAILCOUNT_MBOX_INBOX_DEFAULT}"
	fi
}

