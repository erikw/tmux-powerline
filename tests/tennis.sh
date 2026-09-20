#!/usr/bin/env bash
# Offline regression tests: bash tests/tennis.sh (requires the segment's curl/jq).
set -eu

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
export TENNIS_TEST_DIR="$test_dir"
export TENNIS_TEST_REAL_DATE
TENNIS_TEST_REAL_DATE=$(command -v date)
export XDG_CACHE_HOME="$test_dir/cache"
export TMUX_POWERLINE_SEG_TENNIS_API_KEY="test-key"
mkdir -p "$test_dir/bin"
export PATH="$test_dir/bin:$PATH"

cat >"$test_dir/bin/date" <<'SH'
#!/usr/bin/env bash
if [ "$1" = +%s ]; then
	cat "$TENNIS_TEST_DIR/time"
else
	"$TENNIS_TEST_REAL_DATE" "$@"
fi
SH

cat >"$test_dir/bin/curl" <<'SH'
#!/usr/bin/env bash
set -eu
# Assert the real transport contract, including disabling user curl defaults.
[ "$1" = -q ]
shift
[ "$1" = --silent ] && [ "$2" = --fail ] && [ "$3" = --max-time ] && [ "$4" = 8 ]
shift 4
[ "$1" = --retry ] && [ "$2" = 0 ] && [ "$3" = --header ] && [ "$4" = @- ]
shift 4
[ "$1" = --output ]
output="$2"
shift 2
[ "$1" = --write-out ] && [ "$2" = '%{http_code}' ]
[ "$3" = 'https://api.livetennisapi.com/api/public/v1/matches?status=live&limit=100' ]
[ "$#" = 3 ]
read -r header
[ "$header" = 'X-API-Key: test-key' ]
printf 'request\n' >>"$TENNIS_TEST_DIR/requests"
status=$(cat "$TENNIS_TEST_DIR/status")
cp "$TENNIS_TEST_DIR/response" "$output"
printf '%s' "$status"
[ "$status" = 200 ] || exit 22
SH
chmod +x "$test_dir/bin/date" "$test_dir/bin/curl"

passed=0
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert_equal() { [ "$1" = "$2" ] || fail "expected <$2>, got <$1>"; }
pass() { passed=$((passed + 1)); printf 'ok %s - %s\n' "$passed" "$1"; }
cache="$XDG_CACHE_HOME/tmux-powerline/tennis"
reset_case() {
	rm -rf "$XDG_CACHE_HOME"
	printf '1000000\n' >"$test_dir/time"
	printf '200\n' >"$test_dir/status"
	: >"$test_dir/requests"
	unset TMUX_POWERLINE_SEG_TENNIS_PLAYER
	cat >"$test_dir/response" <<'JSON'
{"data":[{"status":"live","players":{"p1":{"name":"Alice"},"p2":{"name":"Bob"}},"score":{"games":[[6,3],[4,4]],"points":["15","30"]}}],"meta":{"has_more":false}}
JSON
}
# Expand positional arguments in the child shell.
# shellcheck disable=SC2016
render() { "$BASH" -c 'source "$1"; run_segment' _ "$repo/segments/tennis.sh"; }
settle() {
	local tries=0
	while [ -d "$cache/refresh.lock" ]; do
		tries=$((tries + 1))
		[ "$tries" -lt 500 ] || fail 'refresh did not finish'
		sleep 0.01
	done
}
fetch() { render >/dev/null; settle; }
requests() { tr -cd '\n' <"$test_dir/requests" | wc -c | tr -d ' '; }
format_fixture() {
	jq '{fetched_at:1000000,data:.data,more:(.meta.has_more == true)}' "$test_dir/response" >"$test_dir/snapshot"
	# shellcheck disable=SC2016
	"$BASH" -c 'source "$1"; __tennis_format "$2" 1000000' _ "$repo/segments/tennis.sh" "$test_dir/snapshot"
}

reset_case
assert_equal "$(TMUX_POWERLINE_SEG_TENNIS_API_KEY='' render)" ''
assert_equal "$(requests)" 0
[ ! -d "$cache" ] || fail 'disabled segment created cache'
pass 'no key means no output, cache or network'

if TMUX_POWERLINE_SEG_TENNIS_API_KEY=$'bad\nheader' render >"$test_dir/out" 2>"$test_dir/err"; then
	fail 'accepted multiline key'
fi
assert_equal "$(requests)" 0
pass 'invalid key rejected before network'

fetch
assert_equal "$(requests)" 1
assert_equal "$(render)" 'Tennis (0m ago): Alice / Bob 6-4 3-4 (15-30)'
pass 'header-authenticated, single-page request and player-major scores'

for _ in {1..20}; do render >/dev/null & done
wait
settle
assert_equal "$(requests)" 1
printf '1000899\n' >"$test_dir/time"
fetch
assert_equal "$(requests)" 1
assert_equal "$(render)" 'Tennis (14m ago): Alice / Bob 6-4 3-4 (15-30)'
pass 'new processes and concurrent renders preserve the 900-second floor'

printf '1000900\n' >"$test_dir/time"
for _ in {1..20}; do render >/dev/null & done
wait
settle
assert_equal "$(requests)" 2
pass 'concurrent refresh at the boundary makes exactly one request'

rm "$cache/snapshot.json"
fetch
assert_equal "$(requests)" 2
assert_equal "$(render)" 'Tennis: unavailable'
pass 'missing score cache does not erase persisted budget'

for status in 401 403 429 500 000; do
	reset_case
	printf '%s\n' "$status" >"$test_dir/status"
	fetch
	fetch
	assert_equal "$(requests)" 1
	assert_equal "$(render)" 'Tennis: unavailable'
	printf '1000900\n' >"$test_dir/time"
	fetch
	assert_equal "$(requests)" 2
	pass "HTTP/transport failure $status consumes the attempt without immediate retry"
done

reset_case
fetch
printf '1000900\n' >"$test_dir/time"
printf '429\n' >"$test_dir/status"
fetch
assert_equal "$(render)" 'Tennis (15m ago): Alice / Bob 6-4 3-4 (15-30)'
pass 'failed refresh retains the last successful snapshot with its age'

for response in 'not json' '{}' '{"data":null}' '{"data":[null]}'; do
	reset_case
	printf '%s\n' "$response" >"$test_dir/response"
	fetch
	fetch
	assert_equal "$(requests)" 1
	assert_equal "$(render)" 'Tennis: unavailable'
done
pass 'malformed responses do not become empty scoreboards or trigger retries'

reset_case
fetch
printf '999000\n' >"$test_dir/time"
fetch
assert_equal "$(requests)" 1
printf 'broken\n' >"$cache/last_attempt"
fetch
assert_equal "$(requests)" 1
pass 'backwards clock and corrupt budget fail closed'

reset_case
mkdir -p "$cache/refresh.lock"
render >/dev/null
assert_equal "$(requests)" 0
rmdir "$cache/refresh.lock"
fetch
assert_equal "$(requests)" 1
pass 'abandoned lock prevents requests and can be safely removed'

export TMUX_POWERLINE_SEG_TENNIS_PLAYER=ALIce
assert_equal "$(render)" 'Tennis (0m ago): Alice / Bob 6-4 3-4 (15-30)'
export TMUX_POWERLINE_SEG_TENNIS_PLAYER=nobody
assert_equal "$(render)" 'Tennis (0m ago): no matching live match'
assert_equal "$(requests)" 1
unset TMUX_POWERLINE_SEG_TENNIS_PLAYER
pass 'case-insensitive local filtering consumes no extra quota'

printf '%s\n' '{"data":[],"meta":{"has_more":false}}' >"$test_dir/response"
assert_equal "$(format_fixture)" 'Tennis (0m ago): no live matches'
printf '%s\n' '{"data":[],"meta":{"has_more":true}}' >"$test_dir/response"
assert_equal "$(format_fixture)" 'Tennis (0m ago): no match on this page'
pass 'empty and incomplete pages are distinguished'

reset_case
jq '.data[0].score = null' "$test_dir/response" >"$test_dir/edited"
mv "$test_dir/edited" "$test_dir/response"
assert_equal "$(format_fixture)" 'Tennis (0m ago): Alice / Bob score unavailable'
jq '.data[0].score = {games:null,points:[null,null]}' "$test_dir/response" >"$test_dir/edited"
mv "$test_dir/edited" "$test_dir/response"
assert_equal "$(format_fixture)" 'Tennis (0m ago): Alice / Bob score unavailable'
pass 'null scores and withheld games never imply zero scores'

reset_case
jq '.data[0].score.points = [null,null]' "$test_dir/response" >"$test_dir/edited"
mv "$test_dir/edited" "$test_dir/response"
assert_equal "$(format_fixture)" 'Tennis (0m ago): Alice / Bob 6-4 3-4'
jq '.data[0].score |= (.games=[[6],[6]] | .points=["4","3"] | .is_tiebreak=true)' "$test_dir/response" >"$test_dir/edited"
mv "$test_dir/edited" "$test_dir/response"
assert_equal "$(format_fixture)" 'Tennis (0m ago): Alice / Bob 6-6 (TB 4-3)'
pass 'null points are omitted and tiebreak points labelled'

reset_case
jq '.data[0].score.stale = true' "$test_dir/response" >"$test_dir/edited"
mv "$test_dir/edited" "$test_dir/response"
assert_equal "$(format_fixture)" 'Tennis (0m ago): Alice / Bob 6-4 3-4 (15-30) [stale score]'
pass 'provider staleness remains visible on a newly fetched snapshot'

reset_case
jq '.data += [.data[0]] | .meta.has_more = true | .data[0].players.p1.name = "A/B"' "$test_dir/response" >"$test_dir/edited"
mv "$test_dir/edited" "$test_dir/response"
assert_equal "$(format_fixture)" 'Tennis (0m ago): A/B / Bob 6-4 3-4 (15-30) [+1] [more]'
pass 'doubles names, additional matches and page limit are preserved'

reset_case
jq '.data[0].players.p1.name = "#[fg=red]A\n\u001bB"' "$test_dir/response" >"$test_dir/edited"
mv "$test_dir/edited" "$test_dir/response"
assert_equal "$(format_fixture)" 'Tennis (0m ago): ##[fg=red]A  B / Bob 6-4 3-4 (15-30)'
pass 'remote control characters removed and tmux markup escaped'

printf '%s tests passed\n' "$passed"
