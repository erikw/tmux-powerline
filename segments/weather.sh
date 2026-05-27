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
TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD_DEFAULT="86400"
TMUX_POWERLINE_SEG_WEATHER_LAT_DEFAULT="auto"
TMUX_POWERLINE_SEG_WEATHER_LON_DEFAULT="auto"
# Icon style: "emoji" (default), "nerdfonts", "emoji_fixed", "auto"
TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE_DEFAULT="emoji"

TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_data.txt"
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
#   "emoji_fixed" - emoji with VS16 stripped; use if tmux miscounts status-bar width
#   "nerdfonts"   - Nerd Font PUA icons (1 cell, no width ambiguity)
#   "auto"        - nerdfonts when a patched font is detected, else emoji
export TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE="${TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE_DEFAULT}"
EORC
	echo "$rccontents"
}


run_segment() {
	local weather=""
	local update_period="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD:-$TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"

	# Always return cached data immediately (even stale), never block on network
	if [ -f "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" ]; then
		weather=$(__read_file_content "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER")
	fi

	# If cache is stale or missing, trigger a background refresh
	if ! __weather_cache_is_fresh "$update_period"; then
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

	# Bail out if a refresh is already in progress
	[ -f "$lock_file" ] && return

	(
		trap 'rm -f "$lock_file"' EXIT
		touch "$lock_file"

		__process_settings || exit 1

		local weather
		case "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" in
		"yrno")
			weather=$(__yrno)
			;;
		*)
			exit 1
			;;
		esac

		__weather_cache_write "$weather"
	) &
	disown
}


__process_settings() {
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
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE="${TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE_DEFAULT}"
	fi
	if [ "$TMUX_POWERLINE_SEG_WEATHER_LAT" = "auto" ] || [ "$TMUX_POWERLINE_SEG_WEATHER_LON" = "auto" ] || [ -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ] || [ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ]; then
		if ! __get_auto_location; then
			exit 8
		fi
	fi
}


__yrno() {
	if ! command -v curl >/dev/null 2>&1; then
		tp_err_seg "Err: curl not installed"
		return 1
	fi
	if ! command -v jq >/dev/null 2>&1; then
		tp_err_seg "Err: jq not installed"
		return 1
	fi

	local degree=""

	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ] || [ -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ]; then
		tp_err_seg "Err: Unable to auto-detect your location"
		return 1
	fi

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
	local icon_style="${TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE:-$TMUX_POWERLINE_SEG_WEATHER_ICON_STYLE_DEFAULT}"
	if [ "$icon_style" = "auto" ]; then
		tp_patched_font_in_use && icon_style="nerdfonts" || icon_style="emoji"
	fi
	local condition_symbol
	condition_symbol=$(__get_yrno_condition_symbol "$condition" "$icon_style")
	echo "${condition_symbol} ${degree}°$(echo "$TMUX_POWERLINE_SEG_WEATHER_UNIT" | tr '[:lower:]' '[:upper:]')"
}


__degree_c2k() {
	local c="$1"
	echo "${c} + 273.15" | bc
}


__degree_c2f() {
	local c="$1"
	echo "${c} * 9 / 5 + 32" | bc
}


__get_yrno_condition_symbol() {
	local condition="$1"
	local style="$2"

	if [ "$style" = "nerdfonts" ]; then
		# All Nerd Font icons are PUA (1 cell), no width ambiguity
		case "$condition" in
		"clearsky_day")           printf "\UF0599" ;;  # 󰖙 mdi-weather-sunny
		"clearsky_night")         printf "\UF0594" ;;  # 󰖔 mdi-weather-night
		"fair_day")               printf "\UF0595" ;;  # 󰖕 mdi-weather-partly-cloudy
		"fair_night")             printf "\UF0F31" ;;  # 󰼱 mdi-weather-night-partly-cloudy
		"fog")                    printf "\UF0591" ;;  # 󰖑 mdi-weather-fog
		"cloudy")                 printf "\UF0590" ;;  # 󰖐 mdi-weather-cloudy
		"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
			printf "\UF0597" ;;  # 󰖗 mdi-weather-rainy
		"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightssleetshowersandthunder_day" | "lightssleetshowersandthunder_night" | "lightssnowshowersandthunder_day" | "lightssnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
			printf "\UF067E" ;;  # 󰙾 mdi-weather-lightning-rainy
		"heavyrainshowers_day" | "heavysleetshowers_day" | "heavysleetshowersandthunder_night" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
			printf "\UF0F33" ;;  # 󰼳 mdi-weather-partly-rainy
		"heavyrainshowers_night" | "heavysleetshowers_night" | "lightrainshowers_night" | "lightsleetshowers_night" | "rainshowers_night" | "sleetshowers_night")
			printf "\UF0597" ;;  # 󰖗 mdi-weather-rainy
		"snow" | "lightsnow" | "heavysnow")
			printf "\UF0598" ;;  # 󰖘 mdi-weather-snowy
		"lightsnowshowers_day" | "lightsnowshowers_night" | "heavysnowshowers_day" | "heavysnowshowers_night" | "snowshowers_day" | "snowshowers_night")
			printf "\UF0F34" ;;  # 󰼴 mdi-weather-partly-snowy
		"partlycloudy_day")       printf "\UF0595" ;;  # 󰖕 mdi-weather-partly-cloudy
		"partlycloudy_night")     printf "\UF0F31" ;;  # 󰼱 mdi-weather-night-partly-cloudy
		*)                        echo "?" ;;
		esac
	else
		# emoji / emoji_fixed: original symbols with VS16 variation selectors.
		# "emoji_fixed" strips VS16 (U+FE0F) for terminals where Neutral-width base
		# chars like ☀ (U+2600) + VS16 cause tmux to miscalculate status-bar width.
		local symbol
		case "$condition" in
		"clearsky_day")           symbol="☀️ " ;;
		"clearsky_night")         symbol="🌙" ;;
		"fair_day")               symbol="🌤 " ;;
		"fair_night")             symbol="🌜" ;;
		"fog")                    symbol="🌫 " ;;
		"cloudy")                 symbol="☁️ " ;;
		"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
			symbol="🌧 " ;;
		"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightssleetshowersandthunder_day" | "lightssleetshowersandthunder_night" | "lightssnowshowersandthunder_day" | "lightssnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
			symbol="⛈️ " ;;
		"heavyrainshowers_day" | "heavysleetshowers_day" | "heavysleetshowersandthunder_night" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
			symbol="🌦️ " ;;
		"heavyrainshowers_night" | "heavysleetshowers_night" | "lightrainshowers_night" | "lightsleetshowers_night" | "rainshowers_night" | "sleetshowers_night")
			symbol="☔" ;;
		"snow" | "lightsnow" | "heavysnow")
			symbol="❄️ " ;;
		"lightsnowshowers_day" | "lightsnowshowers_night" | "heavysnowshowers_day" | "heavysnowshowers_night" | "snowshowers_day" | "snowshowers_night")
			symbol="🌨 " ;;
		"partlycloudy_day")       symbol="⛅" ;;
		"partlycloudy_night")     symbol="🌗" ;;
		*)                        symbol="?" ;;
		esac
		if [ "$style" = "emoji_fixed" ]; then
			printf '%s' "$symbol" | sed 's/\xef\xb8\x8f//g'
		else
			printf '%s' "$symbol"
		fi
	fi
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


__read_file_content() {
	__read_file_split "$1" 0 ""
}


__read_file_last_update() {
	__read_file_split "$1" 1 0
}


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


__write_to_file_with_last_updated() {
	local file_to_write="$1"
	local content="$2"
	if [ -z "$content" ]; then
		return
	fi
	printf '%s@%s\n' "$content" "$(date +%s)" > "$file_to_write"
}


__weather_cache_write() {
	local content="$1"
	if [ -n "$content" ]; then
		__write_to_file_with_last_updated "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" "$content"
	else
		tp_err_seg "Err: Failed to fetch weather data, caching error message to avoid repeated fetch attempts"
		__write_to_file_with_last_updated "$TMUX_POWERLINE_SEG_WEATHER_CACHE_FILE_WEATHER" "failed to fetch weather data"
	fi
}


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

			if [[ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ||
			      -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ||
			      "$TMUX_POWERLINE_SEG_WEATHER_LAT" == "null" ||
			      "$TMUX_POWERLINE_SEG_WEATHER_LON" == "null" ]]; then
				continue
			fi

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
