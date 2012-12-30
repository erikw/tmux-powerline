# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period of $update_period.

unit="f"

# The update period in seconds.
update_period=600

TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT="yahoo"
TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT="c"
TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT="600"


generate_segmentrc() {
	read -d '' rccontents  << EORC
# The data provider to use. Currently only "yahoo" is supported.
export TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER="${TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT}"
# What unit to use. Can be any of {c,f,k}.
export TMUX_POWERLINE_SEG_WEATHER_UNIT="${TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT}"
# How often to updat the weahter in seconds.
export TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"

# You location. Find a code that works for you:
# 1. Go to Yahoo weather http://weather.yahoo.com/
# 2. Find the weather for you location
# 3. Copy the last numbers in that URL. e.g. "http://weather.yahoo.com/united-states/california/newport-beach-12796587/" has the number "12796587"
export TMUX_POWERLINE_SEG_WEATHER_LOCATION=""
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/weather_yahoo.txt"
	local weather
	case "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" in
		"yahoo") weather=$(__yahoo_weather) ;;
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
		export TMUX_POWERLINE_SEG_WEATHER_UNIT="${TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"
	fi
}

__yahoo_weather() {
	degree=""
	if [ -f "$tmp_file" ]; then
    	if shell_is_osx; then
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
    	weather_data=$(curl --max-time 4 -s "http://weather.yahooapis.com/forecastrss?w=${TMUX_POWERLINE_SEG_WEATHER_LOCATION}&u=${TMUX_POWERLINE_SEG_WEATHER_UNIT}")
    	if [ "$?" -eq "0" ]; then
        	error=$(echo "$weather_data" | grep "problem_cause\|DOCTYPE");
        	if [ -n "$error" ]; then
            	echo "error"
            	exit 1
        	fi
			# <yweather:units temperature="F" distance="mi" pressure="in" speed="mph"/>
    		unit=$(echo "$weather_data" | grep -PZo "<yweather:units [^<>]*/>" | sed 's/.*temperature="\([^"]*\)".*/\1/')
    		condition=$(echo "$weather_data" | grep -PZo "<yweather:condition [^<>]*/>")
			# <yweather:condition  text="Clear"  code="31"  temp="66"  date="Mon, 01 Oct 2012 8:00 pm CST" />
    		degree=$(echo "$condition" | sed 's/.*temp="\([^"]*\)".*/\1/')
    		condition=$(echo "$condition" | sed 's/.*text="\([^"]*\)".*/\1/')
        	echo "$degree" > $tmp_file
        	echo "$condition" >> $tmp_file
    	elif [ -f "$tmp_file" ]; then
        	__read_tmp_file
    	fi
	fi

	if [ -n "$degree" ]; then
    	if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "k" ]; then
        	degree=$(echo "${degree} + 273.15" | bc)
    	fi
    	condition_symbol=$(__get_condition_symbol "$condition")
    	echo "${condition_symbol} ${degree}°${TMUX_POWERLINE_SEG_WEATHER_UNIT^^}"
	fi
}

# Get symbol for condition. Available conditions: http://developer.yahoo.com/weather/#codes
__get_condition_symbol() {
    local condition=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$condition" in
    	"sunny" | "hot")
        	hour=$(date +%H)
        	if [ "$hour" -ge "22" -o "$hour" -le "5" ]; then
            	#echo "☽"
            	echo "☾"
        	else
            	#echo "☀"
            	echo "☼"
        	fi
        	;;
    	"rain" | "mixed rain and snow" | "mixed rain and sleet" | "freezing drizzle" | "drizzle" | "freezing rain" | "showers" | "mixed rain and hail" | "scattered showers" | "isolated thundershowers" | "thundershowers" | "light rain with thunder" | "light rain")
        	#echo "☂"
        	echo "☔"
        	;;
    	"snow" | "mixed snow and sleet" | "snow flurries" | "light snow showers" | "blowing snow" | "sleet" | "hail" | "heavy snow" | "scattered snow showers" | "snow showers" | "light snow")
        	#echo "☃"
        	echo "❅"
        	;;
    	"cloudy" | "mostly cloudy" | "partly cloudy")
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
    	"windy" | "fair/windy")
        	#echo "⚐"
        	echo "⚑"
        	;;
    	"clear" | "fair" | "cold")
        	hour=$(date +%H)
        	if [ "$hour" -ge "22" -o "$hour" -le "5" ]; then
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
    IFS_bak="$IFS"
    IFS=$'\n'
    lines=($(cat ${tmp_file}))
    IFS="$IFS_bak"
    degree="${lines[0]}"
    condition="${lines[1]}"
}
