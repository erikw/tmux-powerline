# shellcheck shell=bash
# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period.
# To configure your location, set TMUX_POWERLINE_SEG_WEATHER_(LAT|LON) in the tmux-powerline config file.
#
# Network fetches are done in a background process so tmux rendering is never blocked.

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"

TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT="yrno"
TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT="c"
TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT="600"
TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD_DEFAULT="86400" # 24 hours
TMUX_POWERLINE_SEG_WEATHER_LAT_DEFAULT="auto"
TMUX_POWERLINE_SEG_WEATHER_LON_DEFAULT="auto"
# Icon style: "emoji" (default), "nerdfonts", "emoji_fixed", "auto"
TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE_DEFAULT="emoji"
TMUX_POWERLINE_SEG_WEATHER_MIN_UPDATE_PERIOD="600"
TMUX_POWERLINE_SEG_WEATHER_FAILURE_RETRY="900"
TMUX_POWERLINE_SEG_WEATHER_FAILURE_RETRY_MAX="21600"
TMUX_POWERLINE_SEG_WEATHER_JITTER_MAX="300"
TMUX_POWERLINE_SEG_WEATHER_MET_ENDPOINT_ENCODED="YWEwNzBqM2I0eTFqZ29xOW4uYXBpLm1ldC5ubw=="

# Global cache file for weather data
TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_data.txt"
# Add: global cache file for auto-detected location (lat/lon)
TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_location.txt"
TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LAST_ATTEMPT="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_last_attempt.txt"
TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_STATE="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_state.txt"
TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCK="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_refresh.lock.d"
TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-powerline"
TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_FILE="${TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DIR}/met-endpoint"
TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_LOCK="${TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DIR}/met-endpoint.lock.d"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# The data provider to use. Currently only "yrno" is supported.
export TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER="${TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT}"
# What unit to use. Can be any of {c,f,k}.
export TMUX_POWERLINE_SEG_WEATHER_UNIT="${TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT}"
# How often to update the weather in seconds.
export TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"
# How often to update the weather location in seconds (this is only used when latitude and longitude settings are set to "auto")
export TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD_DEFAULT}"
# Your location
# Latitude and Longtitude for use with yr.no
# Set both to "auto" to detect automatically based on your IP address, or set them manually
export TMUX_POWERLINE_SEG_WEATHER_LAT="${TMUX_POWERLINE_SEG_WEATHER_LAT_DEFAULT}"
export TMUX_POWERLINE_SEG_WEATHER_LON="${TMUX_POWERLINE_SEG_WEATHER_LON_DEFAULT}"
# Icon style for weather condition symbols:
#   "emoji"       - emoji with VS16 variation selector (default, original behaviour)
#   "emoji_fixed" - emoji with VS16 stripped; fixes status-bar scrolling/duplication
#                   on terminals that miscount VS16 width (see issue #351)
#   "nerdfonts"   - Nerd Font PUA icons (1 cell, no width ambiguity); also fixes #351
#                   if you already use a Nerd Font in your terminal
#   "auto"        - nerdfonts when a patched font is detected, else emoji
# Note: after changing this value, delete the weather cache file to see the effect immediately:
#   rm "${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_data.txt"
#   Run doctor.sh to find out the TMUX_POWERLINE_DIR_TEMPORARY path.
export TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE="${TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	local weather=""

	# Apply non-location defaults following the __process_settings() pattern
	__process_basic_settings

	# Always return cached data immediately (even stale), never block on network
	if [ -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" ]; then
		weather=$(__read_file_content "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER")
	fi

	# If cache is stale or missing, trigger a background refresh
	if ! __weather_cache_is_fresh "$TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD"; then
		__weather_refresh_in_background
	fi

	echo "$weather"
	return 0
}

# Returns 0 if a refresh is not eligible yet, 1 otherwise.
__weather_cache_is_fresh() {
	local time_now next_eligible
	time_now=$(date +%s)
	next_eligible=$(__weather_next_eligible) || return 1
	[ "$next_eligible" -gt "$time_now" ]
}

# Spawn a background process to refresh the cache; does nothing if already running
__weather_refresh_in_background() {
	if ! __weather_state_directory_is_usable; then
		tp_err_seg "Err: Weather cache directory is unavailable; skipping refresh"
		return
	fi

	if [ -d "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCK" ]; then
		if ! __weather_lock_is_stale "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCK" 60; then
			return
		fi
		rmdir "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCK" 2>/dev/null || return
	fi

	mkdir "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCK" 2>/dev/null || return

	(
		exec >/dev/null 2>&1
		trap 'rmdir "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCK" 2>/dev/null' EXIT

		# A renderer may have checked eligibility before another worker updated it.
		__weather_cache_is_fresh "$TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD" && exit 0
		__weather_reserve_attempt || exit 1
		__process_settings || {
			__weather_schedule_failure
			exit 1
		}

		local weather
		case "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" in
		"yrno")
			weather=$(__yrno)
			;;
		*)
			tp_err_seg "Err: Invalid weather data provider: ${TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER}"
			__weather_schedule_failure
			exit 1
			;;
		esac

		if [ -n "$weather" ]; then
			__weather_cache_write "$weather" || __weather_schedule_failure
		fi
	) &
	disown
}

__process_basic_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER="${TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_UNIT" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_UNIT="${TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD_DEFAULT}"
	fi
	# Resolve icon style, including "auto" detection.
	local icon_style="${TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE:-$TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE_DEFAULT}"
	if [ "$icon_style" = "auto" ]; then
		tp_patched_font_in_use && icon_style="nerdfonts" || icon_style="emoji"
	fi
	export TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE="$icon_style"
}

__process_settings() {
	__process_basic_settings
	if [ "$TMUX_POWERLINE_SEG_WEATHER_LAT" = "auto" ] || [ "$TMUX_POWERLINE_SEG_WEATHER_LON" = "auto" ] || [ -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ] || [ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ]; then
		if ! __get_auto_location; then
			exit 8
		fi
	fi
	__weather_prepare_coordinates || {
		tp_err_seg "Err: Invalid weather location"
		return 1
	}
}

# An implementation of a weather provider, just need to echo the result, run_segment() will take care of the rest
__yrno() {
	# Ensure required tools exist
	if ! command -v curl >/dev/null 2>&1; then
		tp_err_seg "Err: curl not installed"
		return 1
	fi
	if ! command -v jq >/dev/null 2>&1; then
		tp_err_seg "Err: jq not installed"
		return 1
	fi

	local degree=""

	# There's a chance that you will get rate limited or both location APIs are not working
	# Then long and lat will be "null", as literal string
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ] || [ -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ]; then
		tp_err_seg "Err: Unable to auto-detect your location"
		return 1
	fi

	local user_agent endpoint weather_data header_file body_file http_status curl_status
	user_agent="tmux-powerline/$(tp_version) (https://github.com/erikw/tmux-powerline)"
	endpoint=$(__weather_endpoint) || {
		tp_err_seg "Err: Weather endpoint is unavailable"
		__weather_schedule_failure
		return 1
	}

	header_file=$(mktemp "${TMUX_POWERLINE_DIR_TEMPORARY}/weather_headers.XXXXXX") || {
		tp_err_seg "Err: Unable to create weather response metadata"
		__weather_schedule_failure
		return 1
	}
	body_file=$(mktemp "${TMUX_POWERLINE_DIR_TEMPORARY}/weather_body.XXXXXX") || {
		rm -f "$header_file"
		tp_err_seg "Err: Unable to create weather response cache"
		__weather_schedule_failure
		return 1
	}

	if [ -n "$TMUX_POWERLINE_SEG_WEATHER_STATE_LAST_MODIFIED" ]; then
		http_status=$(curl --compressed --location --max-time 4 -A "$user_agent" -H "If-Modified-Since: ${TMUX_POWERLINE_SEG_WEATHER_STATE_LAST_MODIFIED}" -sS -D "$header_file" -o "$body_file" -w '%{http_code}' "https://${endpoint}/weatherapi/locationforecast/2.0/compact?lat=${TMUX_POWERLINE_SEG_WEATHER_LAT}&lon=${TMUX_POWERLINE_SEG_WEATHER_LON}")
	else
		http_status=$(curl --compressed --location --max-time 4 -A "$user_agent" -sS -D "$header_file" -o "$body_file" -w '%{http_code}' "https://${endpoint}/weatherapi/locationforecast/2.0/compact?lat=${TMUX_POWERLINE_SEG_WEATHER_LAT}&lon=${TMUX_POWERLINE_SEG_WEATHER_LON}")
	fi
	curl_status=$?
	if [ "$curl_status" -ne 0 ] || ! [[ "$http_status" =~ ^[0-9]{3}$ ]]; then
		rm -f "$header_file" "$body_file"
		tp_err_seg "Err: yr.no err: unable to fetch weather data"
		__weather_schedule_failure
		return 1
	fi

	if [ "$http_status" = "304" ]; then
		__weather_schedule_success "$(__weather_header_value "$header_file" "expires")" "$(__weather_header_value "$header_file" "last-modified")"
		rm -f "$header_file" "$body_file"
		return 0
	fi
	if [ "$http_status" != "200" ]; then
		__weather_schedule_failure "$(__weather_header_value "$header_file" "retry-after")"
		rm -f "$header_file" "$body_file"
		tp_err_seg "Err: yr.no err: provider returned HTTP ${http_status}"
		return 1
	fi

	weather_data=$(cat "$body_file")
	if ! degree=$(printf '%s' "$weather_data" | jq -er '.properties.timeseries[0].data.instant.details.air_temperature'); then
		rm -f "$header_file" "$body_file"
		tp_err_seg "Err: yr.no err: unable to parse temperature"
		__weather_schedule_failure
		return 1
	fi
	if ! condition=$(printf '%s' "$weather_data" | jq -er '.properties.timeseries[0].data.next_1_hours.summary.symbol_code'); then
		rm -f "$header_file" "$body_file"
		tp_err_seg "Err: yr.no err: unable to parse weather condition"
		__weather_schedule_failure
		return 1
	fi
	if [ -z "$degree" ] || [ "$degree" = "null" ]; then
		rm -f "$header_file" "$body_file"
		tp_err_seg "Err: yr.no err: unable to fetch weather data"
		__weather_schedule_failure
		return 1
	fi
	__weather_schedule_success "$(__weather_header_value "$header_file" "expires")" "$(__weather_header_value "$header_file" "last-modified")"
	rm -f "$header_file" "$body_file"

	if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "k" ]; then
		degree=$(__degree_c2k "$degree")
	fi
	if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "f" ]; then
		degree=$(__degree_c2f "$degree")
	fi
	# condition_symbol=$(__get_yrno_condition_symbol "$condition" "$sunrise" "$sunset")
	local condition_symbol
	condition_symbol=$(__get_yrno_condition_symbol "$condition" "${TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE:-emoji}")
	# Write the <content@date>, separated by a @ character, so we can fetch it later on without having to call 'stat'
	echo "${condition_symbol} ${degree}°$(echo "$TMUX_POWERLINE_SEG_WEATHER_UNIT" | tr '[:lower:]' '[:upper:]')"
}

# Convert from Celcius to Lord Kelvins.
__degree_c2k() {
	local c="$1"
	echo "${c} + 273.15" | bc
}

# Convert from Celcius to Fahrenheits.
__degree_c2f() {
	local c="$1"
	echo "${c} * 9 / 5 + 32" | bc
}

# Get symbol for condition. Available symbol names: https://api.met.no/weatherapi/weathericon/2.0/documentation#List_of_symbols
# NOTE: when adding new yr.no condition codes, update all three tables below (nerdfonts, emoji_fixed, emoji).
__get_yrno_condition_symbol() {
	# local condition=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	# local sunrise="$2"
	# local sunset="$3"
	local condition=$1
	local style="${2:-emoji}"

	case "$style" in
	"nerdfonts")
		# Literal UTF-8 glyphs (MDI PUA, 1 cell, no width ambiguity). Bash 3.2-safe.
		case "$condition" in
		"clearsky_day") echo "󰖙 " ;;   # U+F0599 mdi-weather-sunny
		"clearsky_night") echo "󰖔 " ;; # U+F0594 mdi-weather-night
		"fair_day") echo "󰖕 " ;;       # U+F0595 mdi-weather-partly-cloudy
		"fair_night") echo "󰼱 " ;;     # U+F0F31 mdi-weather-night-partly-cloudy
		"fog") echo "󰖑 " ;;            # U+F0591 mdi-weather-fog
		"cloudy") echo "󰖐 " ;;         # U+F0590 mdi-weather-cloudy
		"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
			echo "󰖗 "
			;; # U+F0597 mdi-weather-rainy
		"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysleetshowersandthunder_night" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightsleetshowersandthunder_day" | "lightsleetshowersandthunder_night" | "lightsnowshowersandthunder_day" | "lightsnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
			echo "󰙾 "
			;; # U+F067E mdi-weather-lightning-rainy
		"heavyrainshowers_day" | "heavysleetshowers_day" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
			echo "󰼳 "
			;; # U+F0F33 mdi-weather-partly-rainy
		"heavyrainshowers_night" | "heavysleetshowers_night" | "lightrainshowers_night" | "lightsleetshowers_night" | "rainshowers_night" | "sleetshowers_night")
			echo "󰖗 "
			;; # U+F0597 mdi-weather-rainy
		"snow" | "lightsnow" | "heavysnow")
			echo "󰖘 "
			;; # U+F0598 mdi-weather-snowy
		"lightsnowshowers_day" | "lightsnowshowers_night" | "heavysnowshowers_day" | "heavysnowshowers_night" | "snowshowers_day" | "snowshowers_night")
			echo "󰼴 "
			;;                                # U+F0F34 mdi-weather-partly-snowy
		"partlycloudy_day") echo "󰖕 " ;;   # U+F0595 mdi-weather-partly-cloudy
		"partlycloudy_night") echo "󰼱 " ;; # U+F0F31 mdi-weather-night-partly-cloudy
		*) echo "? " ;;                    # trailing space matches other nerdfonts entries
		esac
		;;
	"emoji_fixed")
		# VS16 (U+FE0F) omitted from Neutral-width base characters (☀ ☁ ⛈ 🌦 ❄) so
		# tmux cell-width counting matches what the terminal renders. No sed needed.
		case "$condition" in
		"clearsky_day") echo "☀ " ;;
		"clearsky_night") echo "🌙" ;;
		"fair_day") echo "🌤 " ;;
		"fair_night") echo "🌜" ;;
		"fog") echo "🌫 " ;;
		"cloudy") echo "☁ " ;;
		"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
			echo "🌧 "
			;;
		"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysleetshowersandthunder_night" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightsleetshowersandthunder_day" | "lightsleetshowersandthunder_night" | "lightsnowshowersandthunder_day" | "lightsnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
			echo "⛈ "
			;;
		"heavyrainshowers_day" | "heavysleetshowers_day" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
			echo "🌦 "
			;;
		"heavyrainshowers_night" | "heavysleetshowers_night" | "lightrainshowers_night" | "lightsleetshowers_night" | "rainshowers_night" | "sleetshowers_night")
			echo "☔"
			;;
		"snow" | "lightsnow" | "heavysnow")
			echo "❄ "
			;;
		"lightsnowshowers_day" | "lightsnowshowers_night" | "heavysnowshowers_day" | "heavysnowshowers_night" | "snowshowers_day" | "snowshowers_night")
			echo "🌨 "
			;;
		"partlycloudy_day") echo "⛅" ;;
		"partlycloudy_night") echo "🌗" ;;
		*) echo "? " ;;
		esac
		;;
	*)
		# emoji: original symbols with VS16 variation selectors (default behaviour)
		case "$condition" in
		"clearsky_day") echo "☀️ " ;;
		"clearsky_night") echo "🌙" ;;
		"fair_day") echo "🌤 " ;;
		"fair_night") echo "🌜" ;;
		"fog") echo "🌫 " ;;
		"cloudy") echo "☁️ " ;;
		"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
			echo "🌧 "
			;;
		"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysleetshowersandthunder_night" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightsleetshowersandthunder_day" | "lightsleetshowersandthunder_night" | "lightsnowshowersandthunder_day" | "lightsnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
			echo "⛈️ "
			;;
		"heavyrainshowers_day" | "heavysleetshowers_day" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
			echo "🌦️ "
			;;
		"heavyrainshowers_night" | "heavysleetshowers_night" | "lightrainshowers_night" | "lightsleetshowers_night" | "rainshowers_night" | "sleetshowers_night")
			echo "☔"
			;;
		"snow" | "lightsnow" | "heavysnow")
			echo "❄️ "
			;;
		"lightsnowshowers_day" | "lightsnowshowers_night" | "heavysnowshowers_day" | "heavysnowshowers_night" | "snowshowers_day" | "snowshowers_night")
			echo "🌨 "
			;;
		"partlycloudy_day") echo "⛅" ;;
		"partlycloudy_night") echo "🌗" ;;
		*) echo "? " ;;
		esac
		;;
	esac
}

__read_file_split() {
	file_to_read="$1"
	lookup_index="$2"
	fallback_value="$3"
	if [ ! -f "$file_to_read" ]; then
		echo "$fallback_value"
		return
	fi
	local -a file_arr
	IFS='@' read -ra file_arr <<<"$(cat "$file_to_read")"
	if [ -z "${file_arr[$lookup_index]}" ]; then
		echo "$fallback_value"
		return
	fi
	echo "${file_arr[$lookup_index]}"
}

# Default to empty/blank
__read_file_content() {
	__read_file_split "$1" 0 ""
}

# Default to 0
__read_file_last_update() {
	__read_file_split "$1" 1 0
}

__weather_effective_update_period() {
	local update_period="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD:-$TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"
	if ! [[ "$update_period" =~ ^[1-9][0-9]*$ ]] || [ "$update_period" -lt "$TMUX_POWERLINE_SEG_WEATHER_MIN_UPDATE_PERIOD" ]; then
		update_period="$TMUX_POWERLINE_SEG_WEATHER_MIN_UPDATE_PERIOD"
	fi
	printf '%s\n' "$update_period"
}

__weather_state_directory_is_usable() {
	mkdir -p "$TMUX_POWERLINE_DIR_TEMPORARY" 2>/dev/null &&
		[ -d "$TMUX_POWERLINE_DIR_TEMPORARY" ] &&
		[ -w "$TMUX_POWERLINE_DIR_TEMPORARY" ]
}

__weather_lock_is_stale() {
	local lock_file="$1"
	local maximum_age="$2"
	local lock_mtime lock_age

	lock_mtime=$(stat -c "%Y" "$lock_file" 2>/dev/null || stat -f "%m" "$lock_file" 2>/dev/null) || return 1
	lock_age=$(( $(date +%s) - lock_mtime ))
	[ "$lock_age" -gt "$maximum_age" ]
}

__weather_read_state() {
	TMUX_POWERLINE_SEG_WEATHER_STATE_NEXT_ELIGIBLE=""
	TMUX_POWERLINE_SEG_WEATHER_STATE_FAILURES="0"
	TMUX_POWERLINE_SEG_WEATHER_STATE_LAST_MODIFIED=""

	if [ ! -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_STATE" ]; then
		return 0
	fi

	local key value
	while IFS='=' read -r key value; do
		case "$key" in
		next_eligible) TMUX_POWERLINE_SEG_WEATHER_STATE_NEXT_ELIGIBLE="$value" ;;
		failures) TMUX_POWERLINE_SEG_WEATHER_STATE_FAILURES="$value" ;;
		last_modified) TMUX_POWERLINE_SEG_WEATHER_STATE_LAST_MODIFIED="$value" ;;
		*) return 1 ;;
		esac
	done <"$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_STATE"

	if ! [[ "$TMUX_POWERLINE_SEG_WEATHER_STATE_NEXT_ELIGIBLE" =~ ^[0-9]+$ ]] ||
		! [[ "$TMUX_POWERLINE_SEG_WEATHER_STATE_FAILURES" =~ ^[0-9]+$ ]] ||
		[[ "$TMUX_POWERLINE_SEG_WEATHER_STATE_LAST_MODIFIED" == *$'\n'* ]]; then
		return 1
	fi
	return 0
}

__weather_write_state() {
	local next_eligible="$1"
	local failures="$2"
	local last_modified="$3"
	if ! [[ "$next_eligible" =~ ^[0-9]+$ ]] || ! [[ "$failures" =~ ^[0-9]+$ ]] ||
		[[ "$last_modified" == *$'\n'* ]]; then
		return 1
	fi
	__write_file_atomically "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_STATE" "next_eligible=${next_eligible}
failures=${failures}
last_modified=${last_modified}"
}

__weather_next_eligible() {
	if ! __weather_read_state; then
		return 1
	fi
	if [ -n "$TMUX_POWERLINE_SEG_WEATHER_STATE_NEXT_ELIGIBLE" ]; then
		printf '%s\n' "$TMUX_POWERLINE_SEG_WEATHER_STATE_NEXT_ELIGIBLE"
		return
	fi

	# Preserve an existing v3.3.0 cooldown after upgrading to the state format.
	if [ -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LAST_ATTEMPT" ]; then
		local last_attempt
		last_attempt=$(cat "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LAST_ATTEMPT")
		if [[ "$last_attempt" =~ ^[0-9]+$ ]]; then
			printf '%s\n' "$((last_attempt + $(__weather_effective_update_period)))"
			return
		fi
	fi
	if [ -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" ]; then
		local last_update
		last_update=$(__read_file_last_update "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER")
		if [[ "$last_update" =~ ^[0-9]+$ ]] && [ "$last_update" -gt 0 ]; then
			printf '%s\n' "$((last_update + $(__weather_effective_update_period)))"
			return
		fi
	fi
	printf '%s\n' 0
}

__weather_reserve_attempt() {
	local time_now next_eligible
	time_now=$(date +%s)
	if ! __weather_read_state; then
		# Do not turn corrupt state into an immediate request loop.
		__weather_write_state "$((time_now + $(__weather_effective_update_period)))" 0 "" || return 1
		return 1
	fi
	next_eligible=$(__weather_next_eligible) || return 1
	[ "$next_eligible" -le "$time_now" ] || return 1
	__weather_write_state "$((time_now + $(__weather_effective_update_period)))" "$TMUX_POWERLINE_SEG_WEATHER_STATE_FAILURES" "$TMUX_POWERLINE_SEG_WEATHER_STATE_LAST_MODIFIED"
}

__weather_parse_http_date() {
	local value="$1"
	local parsed
	parsed=$(date -d "$value" +%s 2>/dev/null || date -j -f "%a, %d %b %Y %T %Z" "$value" +%s 2>/dev/null) || return 1
	[[ "$parsed" =~ ^[0-9]+$ ]] || return 1
	printf '%s\n' "$parsed"
}

__weather_header_value() {
	local header_file="$1"
	local header_name="$2"
	awk -v wanted="$header_name" '
		tolower($0) ~ "^" wanted ":" {
			sub(/^[^:]*:[[:space:]]*/, "")
			sub(/\r$/, "")
			print
			exit
		}
	' "$header_file"
}

__weather_schedule_success() {
	local expires="$1"
	local last_modified="$2"
	local time_now next_eligible expires_at jitter=0
	time_now=$(date +%s)
	next_eligible=$((time_now + $(__weather_effective_update_period)))
	expires_at=$(__weather_parse_http_date "$expires") || expires_at=""
	if [ -n "$expires_at" ] && [ "$expires_at" -gt "$next_eligible" ]; then
		next_eligible="$expires_at"
	fi
	if [ "$TMUX_POWERLINE_SEG_WEATHER_JITTER_MAX" -gt 0 ]; then
		jitter=$((RANDOM % (TMUX_POWERLINE_SEG_WEATHER_JITTER_MAX + 1)))
	fi
	__weather_write_state "$((next_eligible + jitter))" 0 "${last_modified:-$TMUX_POWERLINE_SEG_WEATHER_STATE_LAST_MODIFIED}"
}

__weather_schedule_failure() {
	local retry_after="${1:-}"
	local time_now failures delay retry_after_at
	time_now=$(date +%s)
	__weather_read_state || return 1
	failures=$((TMUX_POWERLINE_SEG_WEATHER_STATE_FAILURES + 1))
	delay="$TMUX_POWERLINE_SEG_WEATHER_FAILURE_RETRY"
	while [ "$failures" -gt 1 ] && [ "$delay" -lt "$TMUX_POWERLINE_SEG_WEATHER_FAILURE_RETRY_MAX" ]; do
		delay=$((delay * 2))
		failures=$((failures - 1))
	done
	# Keep the count, rather than the loop counter used to calculate the delay.
	__weather_read_state || return 1
	failures=$((TMUX_POWERLINE_SEG_WEATHER_STATE_FAILURES + 1))
	[ "$delay" -gt "$TMUX_POWERLINE_SEG_WEATHER_FAILURE_RETRY_MAX" ] && delay="$TMUX_POWERLINE_SEG_WEATHER_FAILURE_RETRY_MAX"
	if [[ "$retry_after" =~ ^[0-9]+$ ]] && [ "$retry_after" -gt "$delay" ]; then
		delay="$retry_after"
	else
		retry_after_at=$(__weather_parse_http_date "$retry_after") || retry_after_at=""
		if [ -n "$retry_after_at" ] && [ "$retry_after_at" -gt "$((time_now + delay))" ]; then
			delay=$((retry_after_at - time_now))
		fi
	fi
	__weather_write_state "$((time_now + delay))" "$failures" "$TMUX_POWERLINE_SEG_WEATHER_STATE_LAST_MODIFIED"
}

__weather_decode_endpoint() {
	local decoded
	decoded=$(printf '%s' "$TMUX_POWERLINE_SEG_WEATHER_MET_ENDPOINT_ENCODED" | base64 -d 2>/dev/null ||
		printf '%s' "$TMUX_POWERLINE_SEG_WEATHER_MET_ENDPOINT_ENCODED" | base64 -D 2>/dev/null) || return 1
	if ! [[ "$decoded" =~ ^[a-z0-9][a-z0-9.-]*\.api\.met\.no$ ]] ||
		[[ "$decoded" == *..* ]] ||
		[[ "$decoded" == *$'\n'* ]]; then
		return 1
	fi
	printf '%s\n' "$decoded"
}

__weather_endpoint_file_is_valid() {
	local expected="$1"
	[ -f "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_FILE" ] || return 1
	awk -v expected="$expected" '
		NR == 1 { valid = ($0 == expected); next }
		{ valid = 0 }
		END { exit (NR == 1 && valid) ? 0 : 1 }
	' "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_FILE"
}

__weather_endpoint() {
	local expected
	expected=$(__weather_decode_endpoint) || return 1
	if __weather_endpoint_file_is_valid "$expected"; then
		printf '%s\n' "$expected"
		return
	fi

	mkdir -p "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DIR" 2>/dev/null ||
		return 1
	[ -d "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DIR" ] &&
		[ -w "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_DIR" ] || return 1

	if [ -d "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_LOCK" ]; then
		if ! __weather_lock_is_stale "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_LOCK" 60; then
			return 1
		fi
		rmdir "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_LOCK" 2>/dev/null || return 1
	fi
	mkdir "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_LOCK" 2>/dev/null || return 1
	if ! __weather_endpoint_file_is_valid "$expected"; then
		(
			umask 077
			__write_file_atomically "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_FILE" "$expected"
		) || {
			rmdir "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_LOCK" 2>/dev/null
			return 1
		}
		chmod 600 "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_FILE" 2>/dev/null || true
	fi
	rmdir "$TMUX_POWERLINE_SEG_WEATHER_ENDPOINT_LOCK" 2>/dev/null || return 1
	printf '%s\n' "$expected"
}

__weather_prepare_coordinates() {
	local latitude longitude
	latitude=$(awk -v value="$TMUX_POWERLINE_SEG_WEATHER_LAT" '
		BEGIN {
			if (value !~ /^-?[0-9]+([.][0-9]+)?$/ || value < -90 || value > 90) exit 1
			printf "%.4f", value
		}
	') || return 1
	longitude=$(awk -v value="$TMUX_POWERLINE_SEG_WEATHER_LON" '
		BEGIN {
			if (value !~ /^-?[0-9]+([.][0-9]+)?$/ || value < -180 || value > 180) exit 1
			printf "%.4f", value
		}
	') || return 1
	TMUX_POWERLINE_SEG_WEATHER_LAT="$latitude"
	TMUX_POWERLINE_SEG_WEATHER_LON="$longitude"
	export TMUX_POWERLINE_SEG_WEATHER_LAT TMUX_POWERLINE_SEG_WEATHER_LON
}

# Atomically write content to avoid renderers reading a truncated cache file.
__write_file_atomically() {
	local file_to_write="$1"
	local content="$2"
	local temporary_file
	temporary_file=$(mktemp "${file_to_write}.XXXXXX") || {
		tp_err_seg "Err: Unable to create temporary weather cache file"
		return 1
	}
	if ! printf '%s\n' "$content" >"$temporary_file"; then
		rm -f "$temporary_file"
		tp_err_seg "Err: Unable to write temporary weather cache file"
		return 1
	fi
	if ! mv -f "$temporary_file" "$file_to_write"; then
		rm -f "$temporary_file"
		tp_err_seg "Err: Unable to update weather cache file"
		return 1
	fi
}

# Write <content@timestamp> to a file, overwriting existing content.
__write_to_file_with_last_updated() {
	local file_to_write="$1"
	local content="$2"
	if [ -z "$content" ]; then
		return 1
	fi
	__write_file_atomically "$file_to_write" "${content}@$(date +%s)"
}

__weather_record_attempt() {
	__write_file_atomically "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LAST_ATTEMPT" "$1"
}

# Weather-specific cache write: only write successful weather data.
__weather_cache_write() {
	local content="$1"
	if [ -n "$content" ]; then
		__write_to_file_with_last_updated "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" "$content"
	else
		tp_err_seg "Err: Failed to fetch weather data; retaining the previous weather cache"
		return 1
	fi
}

# Try setting TMUX_POWERLINE_SEG_WEATHER_LAT & TMUX_POWERLINE_SEG_WEATHER_LON automatically with GeoIP services.
__get_auto_location() {
	local max_cache_age=$TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD
	local -a lat_lon_arr

	if [[ -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION" ]]; then
		local cache_age=$(($(date +%s) - $(__read_file_last_update "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION")))
		if ((cache_age < max_cache_age)); then
			IFS=' ' read -ra lat_lon_arr <<<"$(__read_file_content "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION")"
			TMUX_POWERLINE_SEG_WEATHER_LAT=${lat_lon_arr[0]}
			TMUX_POWERLINE_SEG_WEATHER_LON=${lat_lon_arr[1]}
			if [[ -n "$TMUX_POWERLINE_SEG_WEATHER_LAT" && -n "$TMUX_POWERLINE_SEG_WEATHER_LON" ]]; then
				return 0
			fi
		fi
	fi

	local location_data
	for api in "https://ipapi.co/json" "https://ipinfo.io/json"; do
		if location_data=$(curl --max-time 4 -s "$api"); then
			case "$api" in
			*ipapi.co*)
				TMUX_POWERLINE_SEG_WEATHER_LAT=$(echo "$location_data" | jq -r '.latitude')
				TMUX_POWERLINE_SEG_WEATHER_LON=$(echo "$location_data" | jq -r '.longitude')
				;;
			*ipinfo.io*)
				IFS=',' read -ra loc <<<"$(echo "$location_data" | jq -r '.loc')"
				TMUX_POWERLINE_SEG_WEATHER_LAT="${loc[0]}"
				TMUX_POWERLINE_SEG_WEATHER_LON="${loc[1]}"
				;;
			esac

			# There's no data, move on to the next API, just don't overwrite the previous location
			# Also, there's a case where lat/lon was set to "null" as a string, gotta handle it
			if [[ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ||
				-z "$TMUX_POWERLINE_SEG_WEATHER_LON" ||
				"$TMUX_POWERLINE_SEG_WEATHER_LAT" == "null" ||
				"$TMUX_POWERLINE_SEG_WEATHER_LON" == "null" ]]; then
				continue
			fi

			# Write location using helper to append timestamp
			__write_to_file_with_last_updated "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION" "$TMUX_POWERLINE_SEG_WEATHER_LAT $TMUX_POWERLINE_SEG_WEATHER_LON"
			return 0
		fi
	done

	if [[ -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION" ]]; then
		tp_err_seg "Warn: Using stale location data (failed to refresh)"
		IFS=' ' read -ra lat_lon_arr <<<"$(__read_file_content "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION")"
		TMUX_POWERLINE_SEG_WEATHER_LAT=${lat_lon_arr[0]}
		TMUX_POWERLINE_SEG_WEATHER_LON=${lat_lon_arr[1]}
		if [[ -n "$TMUX_POWERLINE_SEG_WEATHER_LAT" && -n "$TMUX_POWERLINE_SEG_WEATHER_LON" ]]; then
			return 0
		fi
	fi

	tp_err_seg "Err: Could not detect location automatically"
	return 1
}
