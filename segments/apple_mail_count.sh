#!/usr/bin/env osascript
# Returns the number of unread mails in the INBOX of Apple Mail.

tell application "System Events"
  set process_list to (name of every process)
end tell

if process_list contains "Mail" then
  tell application "Mail"
    set a to " " & unread count of inbox
  end tell
end if
