# Report mail count for your mailbox type
# vi: sw=8 ts=8 noet

TMUX_POWERLINE_SEG_MAIL_COUNT_MAILBOX_TYPE_DEFAULT="maildir"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# Mailbox type to use. Can be any of { apple_mail, gmail, maildir, mbox }
export TMUX_POWERLINE_SEG_MAIL_COUNT_MAILBOX_TYPE="${TMUX_POWERLINE_SEG_MAIL_COUNT_MAILBOX_TYPE_DEFAULT}"
EORC
	echo "${rccontents}"
}

run_segment() {
	__process_settings

	script="${TMUX_POWERLINE_DIR_SEGMENTS}/mail_count_${TMUX_POWERLINE_SEG_MAIL_COUNT_MAILBOX_TYPE}.sh"
	if [[ -f ${script} ]]; then
		source  ${script}
		count="$(run_segment)"
		local exitcode="$?"
		if [ "${exitcode}" -ne 0 ]; then
			return ${exitcode}
		fi
		echo "${count}"
	else
		echo "Unknown mailbox type [${TMUX_POWERLINE_SEG_MAIL_COUNT_MAILBOX_TYPE}]";
	fi
	return 0
}

__process_settings() {
	if [ -z "${TMUX_POWERLINE_SEG_MAIL_COUNT_MAILBOX_TYPE}" ]; then
		export TMUX_POWERLINE_SEG_MAIL_COUNT_MAILBOX_TYPE="${TMUX_POWERLINE_SEG_MAIL_COUNT_MAILBOX_TYPE_DEFAULT}"
	fi
}
