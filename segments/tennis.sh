# shellcheck shell=bash
# Low-cadence tennis snapshots. All local instances share one request budget.

generate_segmentrc() {
	cat <<'EORC'
# Optional tennis snapshots; a dedicated FREE Live Tennis API key is sufficient.
export TMUX_POWERLINE_SEG_TENNIS_API_KEY=""
# Optional player/team name substring, filtered locally without extra requests.
# export TMUX_POWERLINE_SEG_TENNIS_PLAYER=""
EORC
}

run_segment() (
	local key="${TMUX_POWERLINE_SEG_TENNIS_API_KEY:-}"
	[ -n "$key" ] || return 0
	if [[ "$key" == *$'\r'* || "$key" == *$'\n'* ]]; then
		printf '%s\n' 'tennis: the API key must be a single line' >&2
		return 1
	fi
	if ! command -v curl >/dev/null || ! command -v jq >/dev/null; then
		printf '%s\n' 'tennis: curl and jq are required' >&2
		return 1
	fi

	local cache="${TMUX_POWERLINE_DIR_TEMPORARY}/tennis"
	local now
	now=$(date +%s) || return 1
	umask 077
	mkdir -p "$cache" || return 1
	if __tennis_due "$cache" "$now"; then
		# mkdir is an atomic, portable lock shared across panes and tmux servers.
		if mkdir "$cache/refresh.lock" 2>/dev/null; then
			__tennis_refresh "$cache" "$key" >/dev/null 2>&1 &
		fi
	fi

	if [ -f "$cache/snapshot.json" ]; then
		__tennis_format "$cache/snapshot.json" "$now" && return 0
	fi
	if [ -f "$cache/initial_wait" ]; then
		printf '%s\n' 'Tennis: waiting for request window'
		return 0
	fi
	printf '%s\n' 'Tennis: unavailable'
)

__tennis_due() {
	local cache="$1" now="$2" attempt
	[ -f "$cache/last_attempt" ] || return 0
	read -r attempt <"$cache/last_attempt" || return 1
	# Corrupt state or a clock moving backwards must not open the request gate.
	[[ "$attempt" =~ ^[0-9]{1,10}$ ]] || return 1
	# 86,400 / 900 = 96 attempts/day, within the FREE tier's 100 requests/day.
	# This fixed floor applies to failures too and cannot be reduced by a setting.
	[ "$((now - 10#$attempt))" -ge 900 ]
}

__tennis_refresh() (
	local cache="$1" key="$2" now status
	trap 'rm -f "$cache/response.tmp" "$cache/snapshot.tmp" "$cache/attempt.tmp"; rmdir "$cache/refresh.lock"' EXIT
	trap 'exit 1' HUP INT TERM
	now=$(date +%s) || return 1
	# Temporary files can disappear on reboot or cleanup. A full initial cooldown
	# keeps those resets from allowing requests less than 900 seconds apart.
	if [ ! -f "$cache/last_attempt" ]; then
		: >"$cache/initial_wait" || return 1
		printf '%s\n' "$now" >"$cache/attempt.tmp" &&
			mv "$cache/attempt.tmp" "$cache/last_attempt"
		return
	fi
	# Another process may have finished between the first check and taking the lock.
	__tennis_due "$cache" "$now" || return 0
	printf '%s\n' "$now" >"$cache/attempt.tmp" &&
		mv "$cache/attempt.tmp" "$cache/last_attempt" || return 1
	rm -f "$cache/initial_wait"

	# Ignore curlrc (which could enable retries/redirects). Send the key on stdin,
	# not in the URL or process arguments. One page and no follow-up requests.
	status=$(printf 'X-API-Key: %s\n' "$key" |
		curl -q --silent --fail --max-time 8 --retry 0 --header @- \
			--output "$cache/response.tmp" --write-out '%{http_code}' \
			'https://api.livetennisapi.com/api/public/v1/matches?status=live&limit=100') || return 1
	[ "$status" = 200 ] || return 1
	jq -e --argjson now "$now" '
		if (.data | type) == "array" and all(.data[]; type == "object") then
			{fetched_at: $now, data: .data, more: (.meta.has_more == true)}
		else error("invalid match list") end
	' "$cache/response.tmp" >"$cache/snapshot.tmp" &&
		mv "$cache/snapshot.tmp" "$cache/snapshot.json"
)

__tennis_format() {
	jq -er --argjson now "$2" --arg player "${TMUX_POWERLINE_SEG_TENNIS_PLAYER:-}" '
		def name: if type == "string" and length > 0 then .[0:24] else "?" end;
		# Match tiebreaks carry points in the final games slot as well. When the
		# two fields agree, show that tiebreak score once, in brackets.
		def shared_tiebreak_points:
			.score.is_tiebreak == true and
			([.score.games[]? | last | tostring] == [.score.points[]? | tostring]);
		def games:
			if (.score.games | type) == "array" and (.score.games | length) == 2
				and all(.score.games[]; type == "array") then
				shared_tiebreak_points as $shared |
				.score.games | transpose | (length - 1) as $last | to_entries |
				map((.value | map(. // "?" | tostring) | join("-")) as $score |
					if $shared and .key == $last then "[" + $score + "]" else $score end) | join(" ")
			else "" end;
		def points:
			if (shared_tiebreak_points | not) and (.score.points | type) == "array" and (.score.points | length) == 2
				and all(.score.points[]; . != null) then
				" (" + (if .score.is_tiebreak == true then "TB " else "" end)
				+ (.score.points | map(tostring) | join("-")) + ")"
			else "" end;
		. as $snapshot |
		[.data[] | select(.status == "live") | select(
			$player == "" or ([.players.p1.name // "", .players.p2.name // ""]
			| join(" ") | ascii_downcase | contains($player | ascii_downcase)))] as $matches |
		"Tennis (" + ([0, (($now - .fetched_at) / 60 | floor)] | max | tostring) + "m ago): " +
		(if ($matches | length) == 0 then
			if $snapshot.more then "no match on this page"
			elif $player != "" then "no matching live match" else "no live matches" end
		else
			$matches[0] | (.players.p1.name | name) + " / " + (.players.p2.name | name) + " " +
			(if (games | length) > 0 then games + points else "score unavailable" end) +
			(if .score.stale == true then " [stale score]" else "" end) +
			(if ($matches | length) > 1 then " [+" + (($matches | length) - 1 | tostring) + "]" else "" end) +
			(if $snapshot.more then " [more]" else "" end)
		end) |
		# Remote names are plain text, never terminal controls or tmux formatting.
		gsub("[\u0000-\u001f\u007f-\u009f]"; " ") | gsub("#"; "##")
	' "$1" 2>/dev/null
}
