#!/usr/bin/env bash
# Offline regression tests: bash tests/weather.sh (requires jq).
set -eu

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
export WEATHER_TEST_DIR="$test_dir"
export WEATHER_TEST_REAL_DATE
WEATHER_TEST_REAL_DATE=$(command -v date)
export TMUX_POWERLINE_DIR_HOME="$repo"
export TMUX_POWERLINE_DIR_LIB="$repo/lib"
export TMUX_POWERLINE_DIR_TEMPORARY="$test_dir/temporary"
export TMUX_POWERLINE_SEG_WEATHER_LAT=59.912345
export TMUX_POWERLINE_SEG_WEATHER_LON=10.751234
export TMUX_POWERLINE_ERROR_LOGS_ENABLED=false
export TMUX_POWERLINE_ERROR_LOGS_SCOPES=
export WEATHER_TEST_CURL_DELAY=0.05
mkdir -p "$test_dir/bin"
export PATH="$test_dir/bin:$PATH"

cat >"$test_dir/bin/date" <<'SH'
#!/usr/bin/env bash
if [ "$1" = +%s ]; then
	cat "$WEATHER_TEST_DIR/time"
elif [ "$1" = -d ] && [ -n "$2" ]; then
	printf '%s\n' 1001200
elif [ "$1" = -j ] && [ -n "$4" ]; then
	printf '%s\n' 1001200
else
	exit 1
fi
SH
chmod +x "$test_dir/bin/date"

cat >"$test_dir/bin/curl" <<'SH'
#!/usr/bin/env bash
set -eu
headers=
body=
write_out=
if_modified_since=
user_agent=
while [ "$#" -gt 0 ]; do
	case "$1" in
	-D) headers=$2; shift 2 ;;
	-o) body=$2; shift 2 ;;
	-w) write_out=$2; shift 2 ;;
	-H)
		case "$2" in
		If-Modified-Since:*) if_modified_since=${2#If-Modified-Since: } ;;
		esac
		shift 2
		;;
	-A) user_agent=$2; shift 2 ;;
	-*) shift ;;
	*) url=$1; shift ;;
	esac
done
printf '%s\n' "$url" >>"$WEATHER_TEST_DIR/urls"
printf '%s\n' "$user_agent" >>"$WEATHER_TEST_DIR/user_agents"
printf '%s\n' "$if_modified_since" >>"$WEATHER_TEST_DIR/if_modified_since"
touch "$WEATHER_TEST_DIR/curl_started"
trap 'touch "$WEATHER_TEST_DIR/curl_finished"' EXIT
sleep "$WEATHER_TEST_CURL_DELAY"

mode=$(cat "$WEATHER_TEST_DIR/met_mode")
case "$mode" in
failure) exit 22 ;;
success|malformed|not_modified|throttled|server_error) ;;
*) exit 64 ;;
esac

case "$mode" in
success|malformed)
	status=200
	retry_after=
	;;
not_modified)
	status=304
	retry_after=
	;;
throttled)
	status=429
	retry_after=3600
	;;
server_error)
	status=503
	retry_after=
	;;
esac

{
	printf 'HTTP/1.1 %s Test\r\n' "$status"
	printf 'Expires: Thu, 01 Jan 1970 00:00:00 GMT\r\n'
	printf 'Last-Modified: Wed, 31 Dec 1969 23:59:00 GMT\r\n'
	[ -z "$retry_after" ] || printf 'Retry-After: %s\r\n' "$retry_after"
	printf '\r\n'
} >"$headers"

if [ "$mode" = success ]; then
	cat >"$body" <<'JSON'
{"properties":{"timeseries":[{"data":{"instant":{"details":{"air_temperature":12}},"next_1_hours":{"summary":{"symbol_code":"clearsky_day"}}}}]}}
JSON
elif [ "$mode" = malformed ]; then
	printf '%s\n' 'not json' >"$body"
else
	: >"$body"
fi

[ "$write_out" = '%{http_code}' ] && printf '%s' "$status"
SH
chmod +x "$test_dir/bin/curl"

passed=0
cache="$TMUX_POWERLINE_DIR_TEMPORARY"
weather_cache="$cache/weather_cache_data.txt"
state_cache="$cache/weather_cache_state.txt"
endpoint_data="dGVzdC5hcGkubWV0Lm5v"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert_equal() { [ "$1" = "$2" ] || fail "expected <$2>, got <$1>"; }
assert_file_contains() { grep -F -- "$2" "$1" >/dev/null || fail "expected <$2> in $1"; }
assert_file_not_contains() { ! grep -F -- "$2" "$1" >/dev/null || fail "unexpected <$2> in $1"; }
pass() { passed=$((passed + 1)); printf 'ok %s - %s\n' "$passed" "$1"; }
requests() { wc -l <"$test_dir/urls" | tr -d ' '; }

# shellcheck disable=SC2016
render() {
	TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DATA="$endpoint_data" \
	TMUX_POWERLINE_SEG_WEATHER_JITTER_MAX=0 \
	"$BASH" -c 'source "$1"; tp_version() { printf "%s" "v4.0.0"; }; TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DATA="$2"; TMUX_POWERLINE_SEG_WEATHER_JITTER_MAX=0; run_segment' _ "$repo/segments/weather.sh" "$endpoint_data"
}
# shellcheck disable=SC2016
render_with_endpoint() {
	TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DATA="$1" \
	TMUX_POWERLINE_SEG_WEATHER_JITTER_MAX=0 \
	"$BASH" -c 'source "$1"; tp_version() { printf "%s" "v4.0.0"; }; TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DATA="$2"; TMUX_POWERLINE_SEG_WEATHER_JITTER_MAX=0; run_segment' _ "$repo/segments/weather.sh" "$1"
}
settle() {
	local tries=0
	while [ ! -f "$test_dir/curl_started" ]; do
		tries=$((tries + 1))
		[ "$tries" -lt 500 ] || fail 'weather refresh did not start'
		sleep 0.01
	done
	tries=0
	while [ ! -f "$test_dir/curl_finished" ]; do
		tries=$((tries + 1))
		[ "$tries" -lt 500 ] || fail 'weather request did not finish'
		sleep 0.01
	done
	sleep 0.1
}
reset_case() {
	rm -rf "$cache"
	mkdir -p "$cache"
	printf '1000000\n' >"$test_dir/time"
	printf 'success\n' >"$test_dir/met_mode"
	: >"$test_dir/urls"
	: >"$test_dir/user_agents"
	: >"$test_dir/if_modified_since"
	rm -f "$test_dir/curl_started" "$test_dir/curl_finished"
}

reset_case
for _ in {1..20}; do render >/dev/null & done
wait
settle
assert_equal "$(requests)" 1
assert_equal "$(render)" '☀️  12°C'
assert_file_contains "$test_dir/urls" 'https://test.api.met.no/weatherapi/locationforecast/2.0/compact?lat=59.9123&lon=10.7512'
assert_file_not_contains "$test_dir/urls" 'https://api.met.no/'
pass 'concurrent renders make one assigned-endpoint request with four-decimal coordinates'

reset_case
printf '☁️  8°C@999900\n' >"$weather_cache"
unset TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD
assert_equal "$(render)" '☁️  8°C'
[ ! -f "$test_dir/curl_started" ] || fail 'fresh legacy cache started a request'
pass 'fresh cache with an unset period uses the default floor'

reset_case
printf 'failure\n' >"$test_dir/met_mode"
render >/dev/null
settle
assert_equal "$(requests)" 1
assert_file_contains "$state_cache" 'next_eligible=1000900'
render >/dev/null
assert_equal "$(requests)" 1
printf '1000900\n' >"$test_dir/time"
rm -f "$test_dir/curl_started" "$test_dir/curl_finished"
render >/dev/null
settle
assert_equal "$(requests)" 2
assert_file_contains "$state_cache" 'next_eligible=1002700'
pass 'transport failures persist exponential retry eligibility'

reset_case
printf 'malformed\n' >"$test_dir/met_mode"
render >/dev/null
settle
assert_equal "$(requests)" 1
render >/dev/null
assert_equal "$(requests)" 1
pass 'malformed responses cannot retry at render frequency'

reset_case
printf '%s\n' 'corrupt state' >"$state_cache"
render >/dev/null
sleep 0.2
assert_equal "$(requests)" 0
assert_file_contains "$state_cache" 'next_eligible=1000600'
pass 'corrupt request state is repaired without an immediate request'

reset_case
render_with_endpoint "ZXZpbC5leGFtcGxlLmNvbQ==" >/dev/null
sleep 0.2
assert_equal "$(requests)" 0
pass 'invalid endpoint never starts a provider request'

reset_case
printf '%s\n' 'next_eligible=1000000' 'failures=0' 'last_modified=Wed, 31 Dec 1969 23:59:00 GMT' >"$state_cache"
printf '☁️  8°C@999000\n' >"$weather_cache"
printf 'not_modified\n' >"$test_dir/met_mode"
render >/dev/null
settle
assert_equal "$(render)" '☁️  8°C'
assert_file_contains "$test_dir/if_modified_since" 'Wed, 31 Dec 1969 23:59:00 GMT'
assert_file_contains "$state_cache" 'next_eligible=1001200'
pass '304 retains stale weather and sends the stored validator'

reset_case
printf 'throttled\n' >"$test_dir/met_mode"
render >/dev/null
settle
assert_file_contains "$state_cache" 'next_eligible=1003600'
pass '429 honors a longer Retry-After delay'

reset_case
printf '%s\n' 'not a directory' >"$test_dir/unwritable-temporary"
TMUX_POWERLINE_DIR_TEMPORARY="$test_dir/unwritable-temporary" render >/dev/null
sleep 0.2
assert_equal "$(requests)" 0
pass 'unwritable weather state never starts a provider request'

reset_case
TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD=1 render >/dev/null
settle
printf '1000599\n' >"$test_dir/time"
rm -f "$test_dir/curl_started" "$test_dir/curl_finished"
TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD=1 render >/dev/null
[ ! -f "$test_dir/curl_started" ] || fail 'short update period bypassed the mandatory floor'
pass 'short configured intervals cannot bypass the mandatory floor'

reset_case
render >/dev/null
settle
assert_file_contains "$test_dir/user_agents" 'tmux-powerline/v4.0.0 (https://github.com/erikw/tmux-powerline)'
pass 'request User-Agent uses the planned 4.0.x release version'

printf '%s\n' "$passed tests passed"
