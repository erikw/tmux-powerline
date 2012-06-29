#!/usr/bin/env bash
# Return the number of new mails in my Maildir inbox.

cd "$(dirname $0)"

if [ "$PLATFORM" == "mac" ]; then
	nbr_new=$(./unread)
else
	if [ ! -d "$HOME/.mail/inbox/new" ]; then
		exit 1
	fi

	nbr_new=$(ls $HOME/.mail/inbox/new/ | wc -l)
fi

if [ "$nbr_new" -gt "0" ]; then
	echo "✉ ${nbr_new}"
fi

exit 0;
