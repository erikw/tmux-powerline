# Return the number of new mails in your Gmail(or Gmail App email) inbox

TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER_DEFAULT="gmail.com"
TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_INTERVAL_DEFAULT="5"

tmp_file="/tmp/tmux-powerline_gmail_count.txt"	# File to store mail count in.
override=false									# When true a force reloaded will be done.

generate_segmentrc() {
	read -d '' rccontents  << EORC
# Enter your Gmail username here WITH OUT @gmail.com.( OR @domain)
export TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_USERNAME=""
# Google password. Recomenned to use application specific password (https://accounts.google.com/b/0/IssuedAuthSubTokens) Leave this empty to get password from OS X keychain.
# For OSX users : MAKE SURE that you add a key to the keychain in the format as follows
# Keychain Item name : http://<value-you-fill-in-server-variable-below>
# Account name : <username-below>@<server-below>
# Password : Your password ( Once again, try to use 2 step-verification and application-specific password)
# See http://support.google.com/accounts/bin/answer.py?hl=en&answer=185833 for more info.
export TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_PASSWORD=""
# Domain name that will complete your email. For normal GMail users it probably is "gmail.com but can be "foo.tld" for Google Apps users.
export TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER="${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER_DEFAULT}"
# How often in minutes to check for new mails.
export TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_INTERVAL="${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_INTERVAL_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings

	# Create the cache file if it doesn't exist.
	if [ ! -f $tmp_file ]; then
		touch $tmp_file
		override=true
	fi

	# Refresh mail count if the tempfile is older than $interval minutes.
	let interval=60*$TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_INTERVAL
	if shell_is_osx; then
		last_update=$(stat -f "%m" ${tmp_file})
	elif shell_is_linux; then
		last_update=$(stat -c "%Y" ${tmp_file})
	fi
	if [ "$(( $(date +"%s") - ${last_update} ))" -gt "$interval" ] || [ "$override" == true ]; then
		if [ -z "$TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_PASSWORD" ]; then # Get password from keychain if it isn't already set.
			if shell_is_osx; then
				__mac_keychain_get_pass "${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_USERNAME}@${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER}" "$TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER"
			else
				echo "Implement your own sexy password fetching mechanism here."
				return 1
			fi
		fi

		# Check for wget before proceeding.
		which wget 2>&1 > /dev/null
		if [ $? -ne 0 ]; then
			echo "This script requires wget." 1>&2
			return 1
		fi

		mail=$(wget -q -O - https://mail.google.com/a/${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER}/feed/atom --http-user="${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_USERNAME}@${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER}" --http-password="${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_PASSWORD}" --no-check-certificate | grep fullcount | sed 's/<[^0-9]*>//g')

		if [ "$mail" != "" ]; then
			echo $mail > $tmp_file
		else
			return 1
		fi
	fi

	# echo "$(( $(date +"%s") - $(stat -f %m $tmp_file) ))"
	mailcount=$(cat $tmp_file)
	echo "✉ $mailcount"
	return 0;
} 

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER" ]; then
		export TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER="${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_SERVER_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_INTERVAL" ]; then
		export TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_INTERVAL="${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_INTERVAL_DEFAULT}"
	fi
}


# Get password from OS X keychain.
__mac_keychain_get_pass() {
	result=$(security 2>&1 > /dev/null find-internet-password -ga $1 -s $2)
	if [ $? -eq 0 ]; then
		TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_PASSWORD=$(echo $result | sed -e 's/password: \"\(.*\)\"/\1/g') #<<< $result)
		# unset $result
		return 0
	fi
	return 1
}
