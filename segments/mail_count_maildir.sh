# Return the number of new mails in a maildir.

run_segment() {
	inbox="$HOME/.mail/inbox/new"

	cd "$(dirname $0)"

	if [ ! -d "$inbox" ]; then
		return 1
	fi

	nbr_new=$(ls "$inbox" | wc -l)

	# Fix for mac, otherwise whitespace is left in output
	if [ "$PLATFORM" == "mac" ]; then
		nbr_new=$(echo "$nbr_new" | sed -e "s/^[ \t]*//")
	fi

	if [ "$nbr_new" -gt "0" ]; then
		echo "✉ ${nbr_new}"
	fi

	return 0;
}
