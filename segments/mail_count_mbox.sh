#!/usr/bin/env bash
# Echo the number of new mails in an mbox

inbox="${MAIL}"

if [ ! -f "${inbox}" ]; then
	exit 1
fi

# This matches the From_ line (see man 5 mbox) e.g.
# From noreply@github.com  Sun Dec  2 03:52:25 2012
# See https://github.com/erikw/tmux-powerline/pull/91#issuecomment-10926053 for discussion.
nbr_new=$(grep -c '^From [^[:space:]]\+  ... ... .. ..:..:.. ....$' ${inbox})

if [ "$nbr_new" -gt "0" ]; then
	echo "✉ ${nbr_new}"
fi

exit 0;
