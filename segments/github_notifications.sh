# shellcheck shell=bash

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SINCE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SINCE:-$(date +%Y-%m-%dT00:00:00Z)}"
TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SINCE_ENABLE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SINCE_ENABLE:-no}"
TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_PER_PAGE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_PER_PAGE:-50}"
TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_MAX_PAGES="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_MAX_PAGES:-10}"
TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_UPDATE_INTERVAL="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_UPDATE_INTERVAL:-60}"
TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SUMMARIZE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SUMMARIZE:-no}"
TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SYMBOL_MODE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SYMBOL_MODE:-yes}"
TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_HIDE_NO_NOTIFICATIONS="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_HIDE_NO_NOTIFICATIONS:-yes}"
TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_TEST_MODE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_TEST_MODE:-no}"

_GITHUB_NOTIFICATIONS_TEST_RESPONSE='
[
  {"reason": "approval_requested"},
  {"reason": "assign"},
  {"reason": "author"},
  {"reason": "comment"},
  {"reason": "ci_activity"},
  {"reason": "invitation"},
  {"reason": "manual"},
  {"reason": "mention"},
  {"reason": "review_requested"},
  {"reason": "security_alert"},
  {"reason": "state_change"},
  {"reason": "subscribed"},
  {"reason": "team_mention"}
]
'

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Github token (https://github.com/settings/tokens) with at least "notifications" scope
export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_TOKEN=""
# Include available notification reasons (https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#about-notification-reasons),
# in the format "REASON:SEPARATOR"
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_REASONS="approval_requested:-󰴄 |assign:-󰎔 |author:-󰔗 |comment:- |ci_activity:-󰙨 |invitation:- |manual:-󱥃 |mention:- |review_requested:- |security_alert:-󰒃 |state_change:-󱇯 |subscribed:- |team_mention:- "
# Or if you don't like so many symbols, try the abbreviation variant
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_REASONS="approval_requested:areq|assign:as|author:au|comment:co|ci_activity:ci|invitation:in|manual:ma|mention:me|review_requested:rreq|security_alert:sec|state_change:st|subscribed:sub|team_mention:team"
# Use symbol mode (ignored if you set TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_REASONS yourself)
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SYMBOL_MODE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SYMBOL_MODE}"
# Summarize all notifications
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SUMMARIZE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SUMMARIZE}"
# Hide if no notifications
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_HIDE_NO_NOTIFICATIONS="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_HIDE_NO_NOTIFICATIONS}"
# Only show new notifications since date (default: today) (takes up to UPDATE_INTERVAL time to take effect)
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SINCE="\$(date +%Y-%m-%dT00:00:00Z)"
# Enable show only notifications since date (takes up to UPDATE_INTERVAL time to take effect)
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SINCE_ENABLE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SINCE_ENABLE}"
# Maximum notifications to retreive per page (upstream github default per_page, 50)
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_PER_PAGE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_PER_PAGE}"
# Maximum pages to retreive
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_MAX_PAGES="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_MAX_PAGES}"
# Update interval to pull latest state from github api
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_UPDATE_INTERVAL="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_UPDATE_INTERVAL}"
# Enable Test Mode (to test how the segment will look like when you have notifications for all types/reasons)
# export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_TEST_MODE="${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_TEST_MODE}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	if ! type curl >/dev/null 2>&1; then
		return 0
	fi

	if [ -z "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_TOKEN" ] && ! is_flag_enabled "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_TEST_MODE"; then
		return 0
	fi

	local tmp_file
	local api_url
	local api_query
	local auth_header

	tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/github_notifications.stat"
	tmp_headers_file="$TMUX_POWERLINE_DIR_TEMPORARY/github_notifications.headers"

	api_url="https://api.github.com/notifications"

	if is_flag_enabled "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SINCE_ENABLE"; then
		api_query="since=${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SINCE}&"
	fi
	api_query="${api_query}per_page=${TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_PER_PAGE}"

	auth_header="Authorization: Bearer $TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_TOKEN"

	if ! is_tmp_valid "$tmp_file" "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_UPDATE_INTERVAL"; then
		if is_flag_enabled "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_TEST_MODE"; then
			notifications=$_GITHUB_NOTIFICATIONS_TEST_RESPONSE
		else
			read -r -d '' notifications < <(curl -s --url "${api_url}?${api_query}" -D "$tmp_headers_file" --header "$auth_header")
			# Handle paging (we only get "link" header when there are more pages)
			# For more information see: https://docs.github.com/en/rest/using-the-rest-api/using-pagination-in-the-rest-api?apiVersion=2022-11-28#using-link-headers
			if link=$(grep '^link: ' "$tmp_headers_file"); then
				# Get last page number
				last_page=$(echo "$link" | sed -r 's/.*page=([0-9]+)>; rel="last".*/\1/' | tr -d '\r\n')
				# We already got the first page, so we start now with page 2
				page=2
				# Get pages until we got the last page or up until configured max pages
				until [ "$page" -gt "$last_page" ] || [ "$page" -gt "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_MAX_PAGES" ]; do
					read -r -d '' _tmp_notifications < <(curl -s --url "${api_url}?${api_query}&page=$page" --header "$auth_header")
					notifications=$(jq -s 'add' <(echo "$notifications") <(echo "$_tmp_notifications"))
					((page++))
				done
			fi
		fi

		all_count=0
		result=""

		IFS=$'|' read -r -a reasons_list <<<"$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_REASONS"

		for reason_entry in "${reasons_list[@]}"; do
			count=0
			IFS=$':' read -r reason separator <<<"$reason_entry"
			count="$(echo "$notifications" | jq -c '.[] | select( .reason == "'"$reason"'" )' | jq -s 'length')"

			if [ "$count" -eq 0 ] && is_flag_enabled "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_HIDE_NO_NOTIFICATIONS"; then
				continue
			fi

			if is_flag_enabled "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SUMMARIZE"; then
				all_count="$((all_count + count))"
			else
				if ! [[ "$separator" =~ ^-.*$ ]]; then
					result="$result $separator:$count"
				else
					result="$result ${separator:1}$count"
				fi
			fi
		done

		if is_flag_enabled "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SUMMARIZE"; then
			if [ "$all_count" -gt 0 ] || ! is_flag_enabled "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_HIDE_NO_NOTIFICATIONS"; then
				echo " $all_count" >"$tmp_file"
			else
				echo -n >"$tmp_file"
			fi
		else
			if [ -n "$result" ] || ! is_flag_enabled "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_HIDE_NO_NOTIFICATIONS"; then
				echo " $result" >"$tmp_file"
			else
				echo -n >"$tmp_file"
			fi
		fi
	fi

	cat "$tmp_file"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_REASONS" ]; then
		if is_flag_enabled "$TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_SYMBOL_MODE"; then
			export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_REASONS="approval_requested:-󰴄 |assign:-󰎔 |author:-󰔗 |comment:- |ci_activity:-󰙨 |invitation:- |manual:-󱥃 |mention:- |review_requested:- |security_alert:-󰒃 |state_change:-󱇯 |subscribed:- |team_mention:- "
		else
			export TMUX_POWERLINE_SEG_GITHUB_NOTIFICATIONS_REASONS="approval_requested:areq|assign:as|author:au|comment:co|ci_activity:ci|invitation:in|manual:ma|mention:me|review_requested:rreq|security_alert:sec|state_change:st|subscribed:sub|team_mention:team"
		fi
	fi
}
