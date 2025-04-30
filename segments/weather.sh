# shellcheck shell=bash
# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period.
# To configure your location, set TMUX_POWERLINE_SEG_WEATHER_(LAT|LON) in the tmux-powerline config file.

TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT="yrno"
TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT="c"
TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT="600"
TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD_DEFAULT="86400" # 24 hours
TMUX_POWERLINE_SEG_WEATHER_LAT_DEFAULT="auto"
TMUX_POWERLINE_SEG_WEATHER_LON_DEFAULT="auto"


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
EORC
	echo "$rccontents"
}


run_segment() {
	local cache_weather_file="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_data.txt"
	local cache_location_file="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_cache_location.txt"
	local weather=""

	# Check if the weather data is still a valid cache hit
	if [ -f "$cache_weather_file" ]; then
		last_update=$(__read_file_last_update "$cache_weather_file")
		time_now=$(date +%s)
		up_to_date=$(echo "(${time_now}-${last_update}) < ${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			weather=$(__read_file_content "$cache_weather_file")
		fi
	fi
	
	# Fetch from provider if empty
	# If a new provider is implemented, please set the $weather variable!
	if [ -z "$weather" ]; then
		__process_settings
		case "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" in
		"yrno")
			weather=$(__yrno)
			;;
		*)
			# Just read the stale cache, default to empty/blank
			# Better not overwriting the previous healthy content
			weather=$(__read_file_content "$cache_weather_file")
			;;
		esac
		echo "$weather" > "$cache_weather_file"
	fi

	echo "$weather"
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
	if [ "$TMUX_POWERLINE_SEG_WEATHER_LAT" = "auto" ] || [ "$TMUX_POWERLINE_SEG_WEATHER_LON" = "auto" ] || [ -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ] || [ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ]; then
		if ! get_auto_location; then
			exit 8
		fi
	fi
}


# An implementation of a weather provider, just need to echo the result, run_segment() will take care of the rest
__yrno() {
	local degree=""

	# There's a chance that you will get rate limited or both location APIs are not working
	# Then long and lat will be "null", as literal string
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ] || [ -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ]; then
		echo "Err: Unable to auto-detect your location"
		return 1
	fi

	if weather_data=$(curl --max-time 4 -s "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=${TMUX_POWERLINE_SEG_WEATHER_LAT}&lon=${TMUX_POWERLINE_SEG_WEATHER_LON}"); then
		error=$(echo "$weather_data" | grep -i "error")
		if [ -n "$error" ]; then
			echo "error"
			return 1
		fi
		degree=$(echo "$weather_data" | jq -r '.properties.timeseries | .[0].data.instant.details.air_temperature')
		condition=$(echo "$weather_data" | jq -r '.properties.timeseries | .[0].data.next_1_hours.summary.symbol_code')
	fi

	if [ -z "$degree" ]; then
		echo "yr.no err: unable to fetch weather data"
		return 1
	fi

	if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "k" ]; then
		degree=$(__degree_c2k "$degree")
	fi
	if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "f" ]; then
		degree=$(__degree_c2f "$degree")
	fi
	# condition_symbol=$(__get_yrno_condition_symbol "$condition" "$sunrise" "$sunset")
	condition_symbol=$(__get_yrno_condition_symbol "$condition")
	# Write the <content@date>, separated by a @ character, so we can fetch it later on without having to call 'stat'
	echo "${condition_symbol} ${degree}°$(echo "$TMUX_POWERLINE_SEG_WEATHER_UNIT" | tr '[:lower:]' '[:upper:]')@$(date +%s)"
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
__get_yrno_condition_symbol() {
	# local condition=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	# local sunrise="$2"
	# local sunset="$3"
	local condition=$1
	case "$condition" in
	"clearsky_day")
		echo "☀️ "
		;;
	"clearsky_night")
		echo "🌙"
		;;
	"fair_day")
		echo "🌤 "
		;;
	"fair_night")
		echo "🌜"
		;;
	"fog")
		echo "🌫 "
		;;
	"cloudy")
		echo "☁️ "
		;;
	"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
		echo "🌧 "
		;;
	"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightssleetshowersandthunder_day" | "lightssleetshowersandthunder_night" | "lightssnowshowersandthunder_day" | "lightssnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
		echo "⛈️ "
		;;
	"heavyrainshowers_day" | "heavysleetshowers_day" | "heavysleetshowersandthunder_night" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
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
	"partlycloudy_day")
		echo "⛅"
		;;
	"partlycloudy_night")
		echo "🌗"
		;;
	*)
		echo "?"
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


get_auto_location() {
    local max_cache_age=$TMUX_POWERLINE_SEG_WEATHER_LOCATION_UPDATE_PERIOD
    local -a lat_lon_arr

    if [[ -f "$cache_location_file" ]]; then
        local cache_age=$(($(date +%s) - $(__read_file_last_update "$cache_location_file")))
        if (( cache_age < max_cache_age )); then
            IFS=' ' read -ra lat_lon_arr <<< "$(__read_file_content "$cache_location_file")"
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

            echo "$TMUX_POWERLINE_SEG_WEATHER_LAT $TMUX_POWERLINE_SEG_WEATHER_LON@$(date +%s)" > "$cache_location_file"
            return 0
        fi
    done

    if [[ -f "$cache_location_file" ]]; then
        echo "Warning: Using stale location data (failed to refresh)" >&2
        IFS=' ' read -ra lat_lon_arr <<< "$(__read_file_content "$cache_location_file")"
        TMUX_POWERLINE_SEG_WEATHER_LAT=${lat_lon_arr[0]}
        TMUX_POWERLINE_SEG_WEATHER_LON=${lat_lon_arr[1]}        
        if [[ -n "$TMUX_POWERLINE_SEG_WEATHER_LAT" && -n "$TMUX_POWERLINE_SEG_WEATHER_LON" ]]; then
            return 0
        fi
    fi

    echo "Could not detect location automatically" >&2
    return 1
}
