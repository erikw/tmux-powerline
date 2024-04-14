# shellcheck shell=bash
# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period.
# To configure your location, set TMUX_POWERLINE_SEG_WEATHER_LOCATION in the tmux-powerline config file.

TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT="yrno"
TMUX_POWERLINE_SEG_WEATHER_JSON_DEFAULT="jq"
TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT="c"
TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT="600"

if shell_is_bsd && [ -f /user/local/bin/grep ]; then
	TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT="/usr/local/bin/grep"
else
	TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT="grep"
fi

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# The data provider to use. Currently only "yahoo" is supported.
export TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER="${TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT}"
# What unit to use. Can be any of {c,f,k}.
export TMUX_POWERLINE_SEG_WEATHER_UNIT="${TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT}"
# How often to update the weather in seconds.
export TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"
# Name of GNU grep binary if in PATH, or path to it.
export TMUX_POWERLINE_SEG_WEATHER_GREP="${TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT}"
# Location of the JSON parser, jq
export TMUX_POWERLINE_SEG_WEATHER_JSON="${TMUX_POWERLINE_SEG_WEATHER_JSON_DEFAULT}"
# Your location
# Latitude and Longtitude for use with yr.no
TMUX_POWERLINE_SEG_WEATHER_LAT=""
TMUX_POWERLINE_SEG_WEATHER_LON=""
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/temp_weather_file.txt"
	local weather
	case "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" in
	"yrno") weather=$(__yrno) ;;
	*)
		echo "Unknown weather provider [$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER]"
		return 1
		;;
	esac
	if [ -n "$weather" ]; then
		echo "$weather"
	fi
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
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_GREP" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_GREP="${TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_JSON" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_JSON="${TMUX_POWERLINE_SEG_WEATHER_JSON_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ] && [ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ]; then
		echo "No location defined."
		exit 8
	fi
}

__yrno() {
	degree=""
	if [ -f "$tmp_file" ]; then
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" "${tmp_file}")
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" "${tmp_file}")
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			__read_tmp_file
		fi
	fi

	if [ -z "$degree" ]; then
		if weather_data=$(curl --max-time 4 -s "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=${TMUX_POWERLINE_SEG_WEATHER_LAT}&lon=${TMUX_POWERLINE_SEG_WEATHER_LON}"); then
			grep=$TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT
			error=$(echo "$weather_data" | $grep -i "error")
			if [ -n "$error" ]; then
				echo "error"
				exit 1
			fi

			jsonparser="${TMUX_POWERLINE_SEG_WEATHER_JSON}"
			degree=$(echo "$weather_data" | $jsonparser -r .properties.timeseries[0].data.instant.details.air_temperature)
			condition=$(echo "$weather_data" | $jsonparser -r .properties.timeseries[0].data.next_1_hours.summary.symbol_code)
		elif [ -f "${tmp_file}" ]; then
			__read_tmp_file
		fi
	fi

	if [ -n "$degree" ]; then
		if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "k" ]; then
			degree=$(echo "${degree} + 273.15" | bc)
		fi
		if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "f" ]; then
			degree=$(echo "${degree} * 9 / 5 + 32" | bc)
		fi
		# condition_symbol=$(__get_yrno_condition_symbol "$condition" "$sunrise" "$sunset")
		condition_symbol=$(__get_yrno_condition_symbol "$condition")
		echo "${condition_symbol} ${degree}°$(echo "$TMUX_POWERLINE_SEG_WEATHER_UNIT" | tr '[:lower:]' '[:upper:]')" | tee "${tmp_file}"
	fi
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

__read_tmp_file() {
	if [ ! -f "$tmp_file" ]; then
		return
	fi
	cat "${tmp_file}"
	exit
}
