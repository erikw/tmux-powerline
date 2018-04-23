# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period of $update_period.

# The update period in seconds.
update_period=600

TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT="yahoo"
TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT="c"
TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT="600"

# If you want to set your location, set TMUX_POWERLINE_SEG_WEATHER_LOCATION in the tmux-powerlinerc file.
# 1. You create tmux-powerlinerc file.
#    $ ./generate_rc.sh
#    $ mv ~/.tmux-powerlinerc.default ~/.tmux-powerlinerc
# 2. You set TMUX_POWERLINE_SEG_WEATHER_LOCATION.

if shell_is_bsd  && [ -f /user/local/bin/grep  ]; then
	TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT="/usr/local/bin/grep"
else
	TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT="grep"
fi


generate_segmentrc() {
	read -d '' rccontents  << EORC
# The data provider to use. Currently only "yahoo" is supported.
export TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER="${TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT}"
# What unit to use. Can be any of {c,f,k}.
export TMUX_POWERLINE_SEG_WEATHER_UNIT="${TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT}"
# How often to update the weather in seconds.
export TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"
# Name of GNU grep binary if in PATH, or path to it.
export TMUX_POWERLINE_SEG_WEATHER_GREP="${TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT}"
# Your location. Find a code that works for you:
# 1. Go to Yahoo weather http://weather.yahoo.com/
# 2. Find the weather for you location
# 3. Copy the last numbers in that URL. e.g. "http://weather.yahoo.com/united-states/california/newport-beach-12796587/" has the numbers "12796587"
TMUX_POWERLINE_SEG_WEATHER_LOCATION=""
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_yahoo.txt"
	local weather
	case "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" in
		"yahoo") weather=$(__yahoo_weather) ;;
		*)
			echo "Unknown weather provider [${$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER}]";
			return 1
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
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_LOCATION" ]; then
		echo "No weather location specified.";
		exit 8
	fi
}

__yahoo_weather() {
	degree=""
	if [ -f "$tmp_file" ]; then
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" ${tmp_file})
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" ${tmp_file})
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			__read_tmp_file
		fi
	fi

	if [ -z "$degree" ]; then
		weather_data=$(curl --max-time 4 -s "https://query.yahooapis.com/v1/public/yql?format=xml&q=SELECT%20*%20FROM%20weather.forecast%20WHERE%20u=%27${TMUX_POWERLINE_SEG_WEATHER_UNIT}%27%20AND%20woeid%20=%20%27${TMUX_POWERLINE_SEG_WEATHER_LOCATION}%27")
		if [ "$?" -eq "0" ]; then
			error=$(echo "$weather_data" | grep "problem_cause\|DOCTYPE");
			if [ -n "$error" ]; then
				echo "error"
				exit 1
			fi

			# Assume latest grep is in PATH
			gnugrep="${TMUX_POWERLINE_SEG_WEATHER_GREP}"

			# <yweather:units temperature="F" distance="mi" pressure="in" speed="mph"/>
			unit=$(echo "$weather_data" | "$gnugrep" -Zo "<yweather:units [^<>]*/>" | sed 's/.*temperature="\([^"]*\)".*/\1/')
			condition=$(echo "$weather_data" | "$gnugrep" -Zo "<yweather:condition [^<>]*/>")
			# <yweather:condition  text="Clear"  code="31"  temp="66"  date="Mon, 01 Oct 2012 8:00 pm CST" />
			degree=$(echo "$condition" | sed 's/.*temp="\([^"]*\)".*/\1/')
			condition=$(echo "$condition" | sed 's/.*text="\([^"]*\)".*/\1/')
			# Pull the times for sunrise and sunset so we know when to change the day/night indicator
			# <yweather:astronomy sunrise="6:56 am"   sunset="6:21 pm"/>
			if shell_is_osx || shell_is_bsd; then
				date_arg='-j -f "%H:%M %p "'
			else
				date_arg='-d'
			fi
			sunrise=$(date ${date_arg}"$(echo "$weather_data" | "$gnugrep" "yweather:astronomy" | sed 's/^\(.*\)sunset.*/\1/' | sed 's/^.*sunrise="\(.*m\)".*/\1/')" +%H%M)
			sunset=$(date ${date_arg}"$(echo "$weather_data" | "$gnugrep" "yweather:astronomy" | sed 's/^.*sunset="\(.*m\)".*/\1/')" +%H%M)
		elif [ -f "${tmp_file}" ]; then
			__read_tmp_file
		fi
	fi

	if [ -n "$degree" ]; then
		if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "k" ]; then
			degree=$(echo "${degree} + 273.15" | bc)
		fi
		condition_symbol=$(__get_condition_symbol "$condition" "$sunrise" "$sunset") 
		echo "${condition_symbol} ${degree}°$(echo "$TMUX_POWERLINE_SEG_WEATHER_UNIT" | tr '[:lower:]' '[:upper:]')" | tee "${tmp_file}"
	fi
}

# Get symbol for condition. Available conditions: http://developer.yahoo.com/weather/#codes
__get_condition_symbol() {
	local condition=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	local sunrise="$2"
	local sunset="$3"
	case "$condition" in
		"sunny" | "hot")
			hourmin=$(date +%H%M)
			if [ "$hourmin" -ge "$sunset" -o "$hourmin" -le "$sunrise" ]; then
				#echo "☽"
				echo "☾"
			else
				#echo "☀"
				echo "☼"
			fi
			;;
		"rain" | "mixed rain and snow" | "mixed rain and sleet" | "freezing drizzle" | "drizzle" | "light drizzle" | "freezing rain" | "showers" | "mixed rain and hail" | "scattered showers" | "isolated thundershowers" | "thundershowers" | "light rain with thunder" | "light rain" | "rain and snow")
			#echo "☂"
			echo "☔"
			;;
		"snow" | "mixed snow and sleet" | "snow flurries" | "light snow showers" | "blowing snow" | "sleet" | "hail" | "heavy snow" | "scattered snow showers" | "snow showers" | "light snow" | "snow/windy" | "snow grains" | "snow/fog")
			#echo "☃"
			echo "❅"
			;;
		"cloudy" | "mostly cloudy" | "partly cloudy" | "partly cloudy/windy")
			echo "☁"
			;;
		"tornado" | "tropical storm" | "hurricane" | "severe thunderstorms" | "thunderstorms" | "isolated thunderstorms" | "scattered thunderstorms")
			#echo "⚡"
			echo "☈"
			;;
		"dust" | "foggy" | "fog" | "haze" | "smoky" | "blustery" | "mist")
			#echo "♨"
			#echo "﹌"
			echo "〰"
			;;
		"breezy")
			#echo "🌬"
			echo "🍃"
			;;
		"windy" | "fair/windy")
			#echo "⚐"
			echo "⚑"
			;;
		"clear" | "fair" | "cold")
			hourmin=$(date +%H%M)
			if [ "$hourmin" -ge "$sunset" -o "$hourmin" -le "$sunrise" ]; then
				echo "☾"
			else
				echo "〇"
			fi
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
