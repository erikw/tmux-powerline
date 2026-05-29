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

# Global cache file for weather data
TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_data.txt"
# Add: global cache file for auto-detected location (lat/lon)
TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_location.txt"


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


# Returns 0 if cache is still fresh, 1 if stale or missing
__weather_cache_is_fresh() {
	local update_period="${1:-$TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"
	[ -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" ] || return 1
	local last_update time_now
	last_update=$(__read_file_last_update "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER")
	time_now=$(date +%s)
	[ "$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)" -eq 1 ]
}


# Spawn a background process to refresh the cache; does nothing if already running
__weather_refresh_in_background() {
	local lock_file="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_refresh.lock"

	# Stale-lock check: if the lock is older than the maximum possible fetch time, treat it as abandoned
	if [ -f "$lock_file" ]; then
		local lock_mtime lock_age=0
		lock_mtime=$(stat -c "%Y" "$lock_file" 2>/dev/null || stat -f "%m" "$lock_file" 2>/dev/null)
		[ -n "$lock_mtime" ] && lock_age=$(( $(date +%s) - lock_mtime ))
		if [ "$lock_age" -le 30 ]; then
			return
		fi
		rm -f "$lock_file"
	fi

	# Atomically acquire the lock; bail out if another invocation beat us to it
	( set -o noclobber; : > "$lock_file" ) 2>/dev/null || return

	(
		exec >/dev/null 2>&1
		trap 'rm -f "$lock_file"' EXIT

		__process_settings || exit 1

		local weather
		case "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" in
		"yrno")
			weather=$(__yrno)
			;;
		*)
			tp_err_seg "Err: Invalid weather data provider: ${TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER}"
			exit 1
			;;
		esac

		__weather_cache_write "$weather"
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

	# Ref: https://api.met.no/doc/TermsOfService
	local user_agent
	user_agent="tmux-powerline/$(tp_version) (https://github.com/erikw/tmux-powerline)"

	if weather_data=$(curl --max-time 4 -A "$user_agent" -s "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=${TMUX_POWERLINE_SEG_WEATHER_LAT}&lon=${TMUX_POWERLINE_SEG_WEATHER_LON}"); then
		error=$(echo "$weather_data" | grep -i "error")
		if [ -n "$error" ]; then
			tp_err_seg "Err: yr.no err: error in api return"
			return 1
		fi
		degree=$(echo "$weather_data" | jq -r '.properties.timeseries | .[0].data.instant.details.air_temperature')
		condition=$(echo "$weather_data" | jq -r '.properties.timeseries | .[0].data.next_1_hours.summary.symbol_code')
	fi

	if [ -z "$degree" ]; then
		tp_err_seg "Err: yr.no err: unable to fetch weather data"
		return 1
	fi

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
		"clearsky_day")           echo "󰖙 " ;;  # U+F0599 mdi-weather-sunny
		"clearsky_night")         echo "󰖔 " ;;  # U+F0594 mdi-weather-night
		"fair_day")               echo "󰖕 " ;;  # U+F0595 mdi-weather-partly-cloudy
		"fair_night")             echo "󰼱 " ;;  # U+F0F31 mdi-weather-night-partly-cloudy
		"fog")                    echo "󰖑 " ;;  # U+F0591 mdi-weather-fog
		"cloudy")                 echo "󰖐 " ;;  # U+F0590 mdi-weather-cloudy
		"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
			echo "󰖗 " ;;  # U+F0597 mdi-weather-rainy
		"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysleetshowersandthunder_night" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightsleetshowersandthunder_day" | "lightsleetshowersandthunder_night" | "lightsnowshowersandthunder_day" | "lightsnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
			echo "󰙾 " ;;  # U+F067E mdi-weather-lightning-rainy
		"heavyrainshowers_day" | "heavysleetshowers_day" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
			echo "󰼳 " ;;  # U+F0F33 mdi-weather-partly-rainy
		"heavyrainshowers_night" | "heavysleetshowers_night" | "lightrainshowers_night" | "lightsleetshowers_night" | "rainshowers_night" | "sleetshowers_night")
			echo "󰖗 " ;;  # U+F0597 mdi-weather-rainy
		"snow" | "lightsnow" | "heavysnow")
			echo "󰖘 " ;;  # U+F0598 mdi-weather-snowy
		"lightsnowshowers_day" | "lightsnowshowers_night" | "heavysnowshowers_day" | "heavysnowshowers_night" | "snowshowers_day" | "snowshowers_night")
			echo "󰼴 " ;;  # U+F0F34 mdi-weather-partly-snowy
		"partlycloudy_day")       echo "󰖕 " ;;  # U+F0595 mdi-weather-partly-cloudy
		"partlycloudy_night")     echo "󰼱 " ;;  # U+F0F31 mdi-weather-night-partly-cloudy
		*)                        echo "? " ;;  # trailing space matches other nerdfonts entries
		esac
		;;
	"emoji_fixed")
		# VS16 (U+FE0F) omitted from Neutral-width base characters (☀ ☁ ⛈ 🌦 ❄) so
		# tmux cell-width counting matches what the terminal renders. No sed needed.
		case "$condition" in
		"clearsky_day")           echo "☀ " ;;
		"clearsky_night")         echo "🌙" ;;
		"fair_day")               echo "🌤 " ;;
		"fair_night")             echo "🌜" ;;
		"fog")                    echo "🌫 " ;;
		"cloudy")                 echo "☁ " ;;
		"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
			echo "🌧 " ;;
		"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysleetshowersandthunder_night" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightsleetshowersandthunder_day" | "lightsleetshowersandthunder_night" | "lightsnowshowersandthunder_day" | "lightsnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
			echo "⛈ " ;;
		"heavyrainshowers_day" | "heavysleetshowers_day" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
			echo "🌦 " ;;
		"heavyrainshowers_night" | "heavysleetshowers_night" | "lightrainshowers_night" | "lightsleetshowers_night" | "rainshowers_night" | "sleetshowers_night")
			echo "☔" ;;
		"snow" | "lightsnow" | "heavysnow")
			echo "❄ " ;;
		"lightsnowshowers_day" | "lightsnowshowers_night" | "heavysnowshowers_day" | "heavysnowshowers_night" | "snowshowers_day" | "snowshowers_night")
			echo "🌨 " ;;
		"partlycloudy_day")       echo "⛅" ;;
		"partlycloudy_night")     echo "🌗" ;;
		*)                        echo "? " ;;
		esac
		;;
	*)
		# emoji: original symbols with VS16 variation selectors (default behaviour)
		case "$condition" in
		"clearsky_day")           echo "☀️ " ;;
		"clearsky_night")         echo "🌙" ;;
		"fair_day")               echo "🌤 " ;;
		"fair_night")             echo "🌜" ;;
		"fog")                    echo "🌫 " ;;
		"cloudy")                 echo "☁️ " ;;
		"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
			echo "🌧 " ;;
		"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysleetshowersandthunder_night" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightsleetshowersandthunder_day" | "lightsleetshowersandthunder_night" | "lightsnowshowersandthunder_day" | "lightsnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
			echo "⛈️ " ;;
		"heavyrainshowers_day" | "heavysleetshowers_day" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
			echo "🌦️ " ;;
		"heavyrainshowers_night" | "heavysleetshowers_night" | "lightrainshowers_night" | "lightsleetshowers_night" | "rainshowers_night" | "sleetshowers_night")
			echo "☔" ;;
		"snow" | "lightsnow" | "heavysnow")
			echo "❄️ " ;;
		"lightsnowshowers_day" | "lightsnowshowers_night" | "heavysnowshowers_day" | "heavysnowshowers_night" | "snowshowers_day" | "snowshowers_night")
			echo "🌨 " ;;
		"partlycloudy_day")       echo "⛅" ;;
		"partlycloudy_night")     echo "🌗" ;;
		*)                        echo "? " ;;
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
	IFS='@' read -ra file_arr <<< "$(cat "$file_to_read")"
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


# Read cached content if still fresh; otherwise output empty
__weather_cache_read() {
	local last_update time_now up_to_date
	if [ ! -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" ]; then
		echo ""
		return
	fi
	last_update=$(__read_file_last_update "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER")
	time_now=$(date +%s)
	up_to_date=$(echo "(${time_now}-${last_update}) < ${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD}" | bc)
	if [ "$up_to_date" -eq 1 ]; then
		__read_file_content "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER"
	else
		echo ""
	fi
}


# Write <content@timestamp> to a file, overwriting existing content
__write_to_file_with_last_updated() {
	local file_to_write="$1"
	local content="$2"
	if [ -z "$content" ]; then
		return
	fi
	printf '%s@%s\n' "$content" "$(date +%s)" > "$file_to_write"
}


# Weather-specific cache write: only write when content is non-empty
__weather_cache_write() {
	local content="$1"
	if [ -n "$content" ]; then
		__write_to_file_with_last_updated "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" "$content"
	else
		# Overwrite the cache file with an error message and updated timestamp to avoid repeated fetch attempts while the provider is unavailable
		tp_err_seg "Err: Failed to fetch weather data, caching error message to avoid repeated fetch attempts"
		__write_to_file_with_last_updated "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" "failed to fetch weather data"
	fi
}


# Try setting TMUX_POWERLINE_SEG_WEATHER_LAT & TMUX_POWERLINE_SEG_WEATHER_LON automatically with GeoIP services.
__get_auto_location() {
    local max_cache_age=$TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD
    local -a lat_lon_arr

    if [[ -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION" ]]; then
        local cache_age=$(($(date +%s) - $(__read_file_last_update "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION")))
        if (( cache_age < max_cache_age )); then
            IFS=' ' read -ra lat_lon_arr <<< "$(__read_file_content "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION")"
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
                    IFS=',' read -ra loc <<< "$(echo "$location_data" | jq -r '.loc')"
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
        IFS=' ' read -ra lat_lon_arr <<< "$(__read_file_content "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_LOCATION")"
        TMUX_POWERLINE_SEG_WEATHER_LAT=${lat_lon_arr[0]}
        TMUX_POWERLINE_SEG_WEATHER_LON=${lat_lon_arr[1]}
        if [[ -n "$TMUX_POWERLINE_SEG_WEATHER_LAT" && -n "$TMUX_POWERLINE_SEG_WEATHER_LON" ]]; then
            return 0
        fi
    fi

    tp_err_seg "Err: Could not detect location automatically"
    return 1
}
