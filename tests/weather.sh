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
export TMUX_POWERLINE_SEG_WEATHER_LAT=59.91
export TMUX_POWERLINE_SEG_WEATHER_LON=10.75
export TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD=600
export WEATHER_TEST_CURL_DELAY=0.05
mkdir -p "$test_dir/bin"
export PATH="$test_dir/bin:$PATH"

cat >"$test_dir/bin/date" <<'SH'
#!/usr/bin/env bash
if [ "$1" = +%s ]; then
	cat "$WEATHER_TEST_DIR/time"
else
	"$WEATHER_TEST_REAL_DATE" "$@"
fi
SH
chmod +x "$test_dir/bin/date"

cat >"$test_dir/bin/curl" <<'SH'
#!/usr/bin/env bash
set -eu
url="${!#}"
touch "$WEATHER_TEST_DIR/curl_started"
trap 'touch "$WEATHER_TEST_DIR/curl_finished"' EXIT
sleep "$WEATHER_TEST_CURL_DELAY"
case "$url" in
*api.met.no*)
	printf 'met\n' >>"$WEATHER_TEST_DIR/requests"
	case "$(cat "$WEATHER_TEST_DIR/met_mode")" in
	success)
	cat <<'JSON'
{"properties":{"timeseries":[{"data":{"instant":{"details":{"air_temperature":12}},"next_1_hours":{"summary":{"symbol_code":"clearsky_day"}}}}]}}
JSON
		;;
	malformed)
		printf '%s\n' 'not json'
		;;
	*)
		exit 22
		;;
	esac
	;;
*ipapi.co*)
	printf 'geoip\n' >>"$WEATHER_TEST_DIR/requests"
	[ "$(cat "$WEATHER_TEST_DIR/geoip_mode")" = success ] || exit 22
	printf '%s\n' '{"latitude":59.91,"longitude":10.75}'
	;;
*ipinfo.io*)
	printf 'geoip\n' >>"$WEATHER_TEST_DIR/requests"
	[ "$(cat "$WEATHER_TEST_DIR/geoip_mode")" = success ] || exit 22
	printf '%s\n' '{"loc":"59.91,10.75"}'
	;;
*)
	exit 64
	;;
esac
SH
chmod +x "$test_dir/bin/curl"

passed=0
cache="$TMUX_POWERLINE_DIR_TEMPORARY"
weather_cache="$cache/weather_cache_data.txt"
attempt_cache="$cache/weather_cache_last_attempt.txt"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert_equal() { [ "$1" = "$2" ] || fail "expected <$2>, got <$1>"; }
pass() { passed=$((passed + 1)); printf 'ok %s - %s\n' "$passed" "$1"; }
requests() { wc -l <"$test_dir/requests" | tr -d ' '; }
met_requests() { grep -c '^met$' "$test_dir/requests" || true; }
geoip_requests() { grep -c '^geoip$' "$test_dir/requests" || true; }

# Expand positional arguments in the child shell.
# shellcheck disable=SC2016
render() { "$BASH" -c 'source "$1"; run_segment' _ "$repo/segments/weather.sh"; }
# shellcheck disable=SC2016
render_auto() {
	TMUX_POWERLINE_SEG_WEATHER_LAT=auto TMUX_POWERLINE_SEG_WEATHER_LON=auto \
		"$BASH" -c 'source "$1"; run_segment' _ "$repo/segments/weather.sh"
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
	sleep 0.2
}
fetch() { render >/dev/null; settle; }
fetch_auto() { render_auto >/dev/null; settle; }
reset_case() {
	rm -rf "$cache"
	mkdir -p "$cache"
	printf '1000000\n' >"$test_dir/time"
	printf 'success\n' >"$test_dir/met_mode"
	printf 'success\n' >"$test_dir/geoip_mode"
	: >"$test_dir/requests"
	rm -f "$test_dir/curl_started" "$test_dir/curl_finished"
}

reset_case
printf '999400\n' >"$attempt_cache"
printf '☁️  8°C@999400\n' >"$weather_cache"
printf '1000000\n' >"$test_dir/time"
for _ in {1..20}; do render >/dev/null & done
wait
settle
assert_equal "$(met_requests)" 1
assert_equal "$(render)" '☀️  12°C'
pass 'concurrent stale renders start exactly one refresh'

reset_case
printf '☁️  8°C@999000\n' >"$weather_cache"
printf '999000\n' >"$attempt_cache"
printf 'failure\n' >"$test_dir/met_mode"
assert_equal "$(render)" '☁️  8°C'
settle
assert_equal "$(met_requests)" 1
assert_equal "$(render)" '☁️  8°C'
fetch
assert_equal "$(met_requests)" 1
printf '1000600\n' >"$test_dir/time"
rm -f "$test_dir/curl_started" "$test_dir/curl_finished"
fetch
assert_equal "$(met_requests)" 2
pass 'failed MET refresh retains stale weather and consumes the attempt window'

reset_case
printf 'failure\n' >"$test_dir/met_mode"
assert_equal "$(render)" ''
settle
assert_equal "$(met_requests)" 1
fetch
assert_equal "$(met_requests)" 1
pass 'first failed MET refresh remains blank without per-render retries'

reset_case
printf 'malformed\n' >"$test_dir/met_mode"
assert_equal "$(render)" ''
settle
assert_equal "$(met_requests)" 1
fetch
assert_equal "$(met_requests)" 1
pass 'malformed MET responses consume the attempt window'

reset_case
printf '☁️  8°C\n' >"$weather_cache"
for _ in {1..20}; do render >/dev/null & done
wait
settle
assert_equal "$(met_requests)" 1
pass 'legacy cache without a timestamp triggers exactly one recovery refresh'

reset_case
printf '☁️  8°C@1000000\n' >"$weather_cache"
printf '1000000\n' >"$attempt_cache"
cat >"$test_dir/bin/bc" <<'SH'
#!/usr/bin/env bash
exit 1
SH
chmod +x "$test_dir/bin/bc"
assert_equal "$(render)" '☁️  8°C'
assert_equal "$(met_requests)" 0
rm "$test_dir/bin/bc"
pass 'fresh weather cache does not depend on bc'

reset_case
printf 'failure\n' >"$test_dir/geoip_mode"
assert_equal "$(render_auto)" ''
settle
assert_equal "$(geoip_requests)" 2
assert_equal "$(met_requests)" 0
fetch_auto
assert_equal "$(geoip_requests)" 2
pass 'failed auto-location lookup is bounded and never calls MET'

reset_case
assert_equal "$(render_auto)" ''
settle
assert_equal "$(geoip_requests)" 1
assert_equal "$(met_requests)" 1
assert_equal "$(render_auto)" '☀️  12°C'
pass 'successful auto-location and MET refresh share one attempt budget'

printf '%s\n' "$passed tests passed"
