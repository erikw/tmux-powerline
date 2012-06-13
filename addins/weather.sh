#!/bin/sh
# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period of $update_period.

# You location. Find a string that works for you by Googling on "weather in <location-string>"
location="Lund, Sweden"

# Can be any of {c,f,k}.
unit="c"

tmp_file="/tmp/weather.txt"

degrees=""
if [ -f "$tmp_file" ]; then
	last_update=$(stat -c "%Y" ${tmp_file})
	time_now=$(date +%s)
	update_period=960

	up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
	if [ "$up_to_date" -eq 1 ]; then
		degrees=$(cat ${tmp_file})
	fi
fi

if [ -z "$degrees" ]; then
	if [ "$unit" == "k" ]; then
		search_unit="c"
	else
		search_unit="$unit"
	fi
	search_location=$(echo "$location" | sed -e 's/\s/%20/g')

	weather_data=$(curl --maxtime 2 -s "http://www.google.com/ig/api?weather=${search_location}")
	if [ "$?" -eq "0" ]; then
		degrees=$(echo "$weather_data" | sed "s|.*<temp_${search_unit} data=\"\([^\"]*\)\"/>.*|\1|")
		echo "$degrees" > $tmp_file
	elif [ -f "$tmp_file" ]; then
		degrees=$(cat "$tmp_file")
	fi
fi

if [ -n "$degrees" ]; then
	if [ "$unit" == "k" ]; then
		degrees=$(echo "${degrees} + 273.15" | bc)
	fi
	unit_upper=$(echo "$unit" | tr '[cfk]' '[CFK]')
	echo "${degrees}°${unit_upper}"
fi
