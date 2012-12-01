#!/usr/bin/env bash
# Echo the number of new mails in an mbox

inbox="${MAIL}"

if [ ! -f "${inbox}" ]; then
	exit 1
fi

nbr_new=$(grep -c '^From [^[:space:]]\+  ... ... .. ..:..:.. ....$' ${inbox})

if [ "$nbr_new" -gt "0" ]; then
	echo "✉ ${nbr_new}"
fi

exit 0;
