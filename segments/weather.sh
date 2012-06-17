#!/bin/bash
# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period of $update_period.

# You location. Find a string that works for you by Googling on "weather in <location-string>"
location="Lund, Sweden"

# Can be any of {c,f,k}.
unit="c"

tmp_file="/tmp/weather.txt"

get_condition_symbol() {
	local conditions=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	case "$conditions" in
	sunny | "partly sunny" | "mostly sunny")
		#echo "☀"
		echo "☼"
		;;
	"rain and snow" | "chance of rain" | "light rain" | rain | "heavy rain" | "freezing drizzle" | flurries | showers | "scattered showers")
		#echo "☂"
		echo "☔"
		;;
	snow | "light snow" | "scattered snow showers" | icy | ice/snow | "chance of snow" | "snow showers" | sleet)
		#echo "☃"
		echo "❅"
		;;
	"partly cloudy" | "mostly cloudy" | cloudy | overcast)
		echo "☁"
		;;
	"chance of storm" | thunderstorm | "chance of tstorm" | storm | "scattered thunderstorms")
		#echo "⚡"
		echo "☈"
		;;
	dust | fog | smoke | haze | mist)
		echo "♨"
		;;
	windy)
		echo "⚑"
		#echo "⚐"
		;;
	clear)
		#echo "☐"
		echo "✈"	# So clear you can see the aeroplanes! TODO what symbol does best represent a clear sky?
		;;
	*)
		echo "？"
		;;
	esac
}

read_tmp_file() {
	if [ ! -f "$tmp_file" ]; then
		return
	fi
	IFS_bak="$IFS"
	IFS=$'\n'
	lines=($(cat ${tmp_file}))
	IFS="$IFS_bak"
	degrees="${lines[0]}"
	conditions="${lines[1]}"
}

degrees=""
if [ -f "$tmp_file" ]; then
	last_update=$(stat -c "%Y" ${tmp_file})
	time_now=$(date +%s)
	update_period=600

	up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
	if [ "$up_to_date" -eq 1 ]; then
		read_tmp_file
	fi
fi

if [ -z "$degrees" ]; then
	if [ "$unit" == "k" ]; then
		search_unit="c"
	else
		search_unit="$unit"
	fi
	search_location=$(echo "$location" | sed -e 's/\s/%20/g')

	weather_data=$(curl --max-time 2 -s "http://www.google.com/ig/api?weather=${search_location}")
	if [ "$?" -eq "0" ]; then
		degrees=$(echo "$weather_data" | sed "s|.*<temp_${search_unit} data=\"\([^\"]*\)\"/>.*|\1|")
		conditions=$(echo "$weather_data" | grep -PZo "<current_conditions>(\\n|.)*</current_conditions>" | grep -PZo "(?<=<condition\sdata=\")([^\"]*)")
		echo "$degrees" > $tmp_file
		echo "$conditions" >> $tmp_file
	elif [ -f "$tmp_file" ]; then
		read_tmp_file
	fi
fi

if [ -n "$degrees" ]; then
	if [ "$unit" == "k" ]; then
		degrees=$(echo "${degrees} + 273.15" | bc)
	fi
	unit_upper=$(echo "$unit" | tr '[cfk]' '[CFK]')
	condition_symbol=$(get_condition_symbol "$conditions")
	echo "${condition_symbol} ${degrees}°${unit_upper}"
fi
