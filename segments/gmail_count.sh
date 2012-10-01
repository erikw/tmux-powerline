#!/usr/bin/env bash
# gmail_count.sh - Return the number of new mails in your gmail inbox

USER= # Enter your gmail username here

# You really shouldn't store your password in cleartext. Use the Mac OS X keychain,
# or some other encrypted password management solution that can be accessed from the terminal.
# You may enter your password below, but you do so at your own peril! 
# Also, for optimum security, don't use your account password. Enable 2-step verification
# on your Google account, and set up an application-specific password for this script, 
# then store that in your keychain. 
# See http://support.google.com/accounts/bin/answer.py?hl=en&answer=185833 for more info.

PASS="" # Leave this empty to get password from keychain
INTERVAL=5 # Query interval in minutes 

TMP_FILE=/tmp/tmux-gmail_count.txt # File to store mail count in

mac_keychain_get_pass() {
    result=`security 2>&1 > /dev/null find-generic-password -ga $1`
    if [ $? -eq 0 ]; then
        PASS=`echo $result | sed -e 's/password: \"\(.*\)\"/\1/g'` #<<< $result`
        # unset $result
        return 0
    fi
    exit 1
}

override=false

# Create the cache file if it doesn't exist
if [ ! -f $TMP_FILE ]
then
    touch $TMP_FILE
    override=true
fi

# Refresh mail count if the tempfile is older than $INTERVAL minutes
let interval=60*$INTERVAL
if [ "$(( $(date +"%s") - $(stat -f %m $TMP_FILE) ))" -gt $interval ] || [ $override == true ]
then

    if [ -z $PASS ] # Get password from keychain if it isn't already set
    then
        if [ "$PLATFORM" == "mac" ]; then
            mac_keychain_get_pass $USER
        else
            echo "Implement your own sexy password fetching mechanism here"
            exit 1
        fi
    fi

    # Check for wget before proceeding
    which wget 2>&1 > /dev/null
    if [ $? -ne 0 ]; then
        echo "This script requires wget"
        exit 1
    fi

    mail=`wget -q -O - https://mail.google.com/a/gmail.com/feed/atom --http-user=$USER@gmail.com --http-password="$PASS" --no-check-certificate | 
        grep fullcount | 
        sed 's/<[^0-9]*>//g'`

        if [ "$mail" != "" ]
        then
            echo $mail > $TMP_FILE
        else
            exit 1
        fi
fi
let interval=$INTERVAL*60
# echo "$(( $(date +"%s") - $(stat -f %m $TMP_FILE) ))"
mailcount=`cat $TMP_FILE`
echo "✉ $mailcount"
exit 0;
