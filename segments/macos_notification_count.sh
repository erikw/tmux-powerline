# Report macOS notification counts for given app ids (banner notifications only)
# Based on http://www.ign.com/boards/threads/a-crumby-way-to-get-an-unread-count-of-imessages-into-applescript.453061379/

TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_APPIDS_DEFAULT="5"
TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_CHAR_DEFAULT="💬"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# App ids to query in notification center, separated by space
# To get the app id that is associated with a specific app run:
# sqlite3 -list "$(getconf DARWIN_USER_DIR)/com.apple.notificationcenter/db/db" 'select * from app_info'
# The first column contains the app ids
# "5" is the app id of Messages.app
# Only "banner" notifications are supported (see settings in the notification center)
export TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_APPIDS="${TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_APPIDS_DEFAULT}"
# Notification symbol
export TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_CHAR="${TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_CHAR_DEFAULT}"
EORC
	echo "${rccontents}"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_APPIDS" ]; then
        export TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_APPIDS="${TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_APPIDS_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_CHAR" ]; then
		export TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_CHAR="${TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_CHAR_DEFAULT}"
	fi
}

run_segment() {
	__process_settings

	local db_location app_ids_array query_condition query_string count
	db_location="$(getconf DARWIN_USER_DIR)/com.apple.notificationcenter/db/db"
	app_ids_array=(${TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_APPIDS})
	query_condition="where app_id=${app_ids_array[0]}"
	for app_id in "${app_ids_array[@]:1}"; do
		query_condition="${query_condition} OR app_id=${app_id}"
	done
    query_string="select count(*) from notifications ${query_condition}"
	count=$(sqlite3 -list ${db_location} "${query_string}")

	local exitcode="$?"
	if [ "$exitcode" -ne 0 ]; then
		return $exitcode
	fi

	if [[ -n "$count"  && "$count" -gt 0 ]]; then
		echo "${TMUX_POWERLINE_SEG_MACOS_NOTIFICATION_COUNT_CHAR} ${count}"
	fi

	return 0
}
