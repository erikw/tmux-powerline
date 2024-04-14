# shellcheck shell=bash
TMUX_POWERLINE_SEG_AIR_DATA_PROVIDER_DEFAULT="openweather"
TMUX_POWERLINE_SEG_AIR_JSON_DEFAULT="jq"
TMUX_POWERLINE_SEG_AIR_UPDATE_PERIOD_DEFAULT="600"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# The data provider to use. Currently only "openweather" is supported.
export TMUX_POWERLINE_SEG_AIR_DATA_PROVIDER="${TMUX_POWERLINE_SEG_AIR_DATA_PROVIDER_DEFAULT}"
# How often to update the weather in seconds.
export TMUX_POWERLINE_SEG_AIR_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_AIR_UPDATE_PERIOD_DEFAULT}"
# Location of the JSON parser, jq
export TMUX_POWERLINE_SEG_AIR_JSON="${TMUX_POWERLINE_SEG_AIR_JSON_DEFAULT}"
# Your location
# Latitude and Longitude:
TMUX_POWERLINE_SEG_AIR_LAT=""
TMUX_POWERLINE_SEG_AIR_LON=""
# Your Open Weather API Key:
TMUX_POWERLINE_SEG_AIR_OPEN_WEATHER_API_KEY=""
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/temp_air_file.txt"
	local air
	case "$TMUX_POWERLINE_SEG_AIR_DATA_PROVIDER" in
	"openweather")
		air=$(__openweather)
		;;
	*)
		echo "Unknown weather provider [${TMUX_POWERLINE_SEG_AIR_DATA_PROVIDER}]"
		return 1
		;;
	esac
	trimmed_air=$(echo "$air" | cut -d' ' -f1-3)

	if [ -n "$trimmed_air" ]; then
		echo "$trimmed_air"
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_AIR_DATA_PROVIDER" ]; then
		export TMUX_POWERLINE_SEG_AIR_DATA_PROVIDER="${TMUX_POWERLINE_SEG_AIR_DATA_PROVIDER_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_AIR_UPDATE_PERIOD" ]; then
		export TMUX_POWERLINE_SEG_AIR_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_AIR_UPDATE_PERIOD_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_AIR_JSON" ]; then
		export TMUX_POWERLINE_SEG_AIR_JSON="${TMUX_POWERLINE_SEG_AIR_JSON_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_AIR_LAT" ] && [ -z "$TMUX_POWERLINE_SEG_AIR_LON" ]; then
		echo "No location defined."
		exit 8
	fi
	if [ -z "$TMUX_POWERLINE_SEG_AIR_OPEN_WEATHER_API_KEY" ]; then
		echo "No API Key defined."
		exit 8
	fi
}

__openweather() {
	carbon_monoxide=""
	if [ -f "$tmp_file" ]; then
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" "${tmp_file}")
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" "${tmp_file}")
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${TMUX_POWERLINE_SEG_AIR_UPDATE_PERIOD}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			__read_tmp_file
		fi
	fi

	if [ -z "$carbon_monoxide" ]; then
		if air_quality_data=$(curl --max-time 4 -s "http://api.openweathermap.org/data/2.5/air_pollution?lat=${TMUX_POWERLINE_SEG_AIR_LAT}&lon=${TMUX_POWERLINE_SEG_AIR_LON}&appid=${TMUX_POWERLINE_SEG_AIR_OPEN_WEATHER_API_KEY}"); then
			error=$(echo "$air_quality_data" | grep -i "error")
			if [ -n "$error" ]; then
				echo "error"
				exit 1
			fi

			jsonparser="${TMUX_POWERLINE_SEG_AIR_JSON}"
			carbon_monoxide=$(echo "$air_quality_data" | $jsonparser -r .list[0].components.co)
			nitrogen_dioxide=$(echo "$air_quality_data" | $jsonparser -r .list[0].components.no2)
			ozone=$(echo "$air_quality_data" | $jsonparser -r .list[0].components.o3)
			sulphur_dioxide=$(echo "$air_quality_data" | $jsonparser -r .list[0].components.so2)
			fine_particle_matter=$(echo "$air_quality_data" | $jsonparser -r .list[0].components.pm2_5)
			coarse_particulate_matter=$(echo "$air_quality_data" | $jsonparser -r .list[0].components.pm10)

		elif [ -f "${tmp_file}" ]; then
			__read_tmp_file
		fi
	fi

	if [ -n "$carbon_monoxide" ]; then
		__get_us_aqi_score "$carbon_monoxide" "$nitrogen_dioxide" "$ozone" "$sulphur_dioxide" "$fine_particle_matter" "$coarse_particulate_matter"
	fi
}

__get_us_aqi_score() {
	local carbon_monoxide=$1
	local nitrogen_dioxide=$2
	local ozone=$3
	local sulphur_dioxide=$4
	local fine_particle_matter=$5
	local coarse_particulate_matter=$6

	carbon_monoxide_ppm=$(__convert_uqgm3_ppm "$carbon_monoxide")
	nitrogen_dioxide_ppb=$(__convert_uqgm3_ppb "$nitrogen_dioxide" "46.01")
	ozone_ppb=$(__convert_uqgm3_ppb "$ozone" "48.00")
	sulphur_dioxide_ppb=$(__convert_uqgm3_ppb "$sulphur_dioxide" "64.06")

	# CO ppm (8-hr)
	if (($(echo "$carbon_monoxide_ppm < 4.5" | bc -l))); then
		carbon_monoxide_aqi_value=$(echo "scale=3; (50/4.4) * $carbon_monoxide_ppm" | bc -l)
	elif (($(echo "$carbon_monoxide_ppm < 9.5" | bc -l))); then
		carbon_monoxide_aqi_value=$(echo "scale=3; (49/4.9) * ($carbon_monoxide_ppm - 4.5) + 51" | bc -l)
	elif (($(echo "$carbon_monoxide_ppm < 12.5" | bc -l))); then
		carbon_monoxide_aqi_value=$(echo "scale=3; (49/2.9) * ($carbon_monoxide_ppm - 9.5) + 101" | bc -l)
	elif (($(echo "$carbon_monoxide_ppm < 15.5" | bc -l))); then
		carbon_monoxide_aqi_value=$(echo "scale=3; (49/2.9) * ($carbon_monoxide_ppm - 12.5) + 151" | bc -l)
	elif (($(echo "$carbon_monoxide_ppm < 30.5" | bc -l))); then
		carbon_monoxide_aqi_value=$(echo "scale=3; (99/14.9) * ($carbon_monoxide_ppm - 15.5) + 201" | bc -l)
	elif (($(echo "$carbon_monoxide_ppm < 40.5" | bc -l))); then
		carbon_monoxide_aqi_value=$(echo "scale=3; (99/9.9) * ($carbon_monoxide_ppm - 30.5) + 301" | bc -l)
	elif (($(echo "$carbon_monoxide_ppm < 50.5" | bc -l))); then
		carbon_monoxide_aqi_value=$(echo "scale=3; (99/9.9) * ($carbon_monoxide_ppm - 40.5) + 401" | bc -l)
	fi

	# NO2 ppb (1-hr)
	if (($(echo "$nitrogen_dioxide_ppb < 54" | bc -l))); then
		nitrogen_dioxide_aqi_value=$(echo "scale=3; (50/53) * $nitrogen_dioxide_ppb" | bc -l)
	elif (($(echo "$nitrogen_dioxide_ppb < 101" | bc -l))); then
		nitrogen_dioxide_aqi_value=$(echo "scale=3; (49/46) * ($nitrogen_dioxide_ppb - 54) + 51" | bc -l)
	elif (($(echo "$nitrogen_dioxide_ppb < 361" | bc -l))); then
		nitrogen_dioxide_aqi_value=$(echo "scale=3; (49/259) * ($nitrogen_dioxide_ppb - 101) + 101" | bc -l)
	elif (($(echo "$nitrogen_dioxide_ppb < 650" | bc -l))); then
		nitrogen_dioxide_aqi_value=$(echo "scale=3; (49/288) * ($nitrogen_dioxide_ppb - 361) + 151" | bc -l)
	elif (($(echo "$nitrogen_dioxide_ppb < 1250" | bc -l))); then
		nitrogen_dioxide_aqi_value=$(echo "scale=3; (99/599) * ($nitrogen_dioxide_ppb - 650) + 201" | bc -l)
	elif (($(echo "$nitrogen_dioxide_ppb < 1650" | bc -l))); then
		nitrogen_dioxide_aqi_value=$(echo "scale=3; (99/399) * ($nitrogen_dioxide_ppb - 1250) + 301" | bc -l)
	elif (($(echo "$nitrogen_dioxide_ppb < 2050" | bc -l))); then
		nitrogen_dioxide_aqi_value=$(echo "scale=3; (99/399) * ($nitrogen_dioxide_ppb - 1650) + 401" | bc -l)
	fi

	# O3 ppb (8-hr)
	if (($(echo "$ozone_ppb < 55" | bc -l))); then
		ozone_aqi_value=$(echo "scale=3; (50/54) * $ozone_ppb" | bc -l)
	elif (($(echo "$ozone_ppb < 71" | bc -l))); then
		ozone_aqi_value=$(echo "scale=3; (49/15) * ($ozone_ppb - 55) + 51" | bc -l)
	elif (($(echo "$ozone_ppb < 86" | bc -l))); then
		ozone_aqi_value=$(echo "scale=3; (49/14) * ($ozone_ppb - 71) + 101" | bc -l)
	elif (($(echo "$ozone_ppb < 106" | bc -l))); then
		ozone_aqi_value=$(echo "scale=3; (49/19) * ($ozone_ppb - 86) + 151" | bc -l)
	elif (($(echo "$ozone_ppb < 201" | bc -l))); then
		ozone_aqi_value=$(echo "scale=3; (99/94) * ($ozone_ppb - 106) + 201" | bc -l)
	fi

	# SO2 ppb (1-hr)
	if (($(echo "$sulphur_dioxide_ppb < 36" | bc -l))); then
		sulphur_dioxide_aqi_value=$(echo "scale=3; (50/35) * $sulphur_dioxide_ppb" | bc -l)
	elif (($(echo "$sulphur_dioxide_ppb < 76" | bc -l))); then
		sulphur_dioxide_aqi_value=$(echo "scale=3; (49/39) * ($sulphur_dioxide_ppb - 36) + 51" | bc -l)
	elif (($(echo "$sulphur_dioxide_ppb < 186" | bc -l))); then
		sulphur_dioxide_aqi_value=$(echo "scale=3; (49/109) * ($sulphur_dioxide_ppb - 76) + 101" | bc -l)
	elif (($(echo "$sulphur_dioxide_ppb < 305" | bc -l))); then
		sulphur_dioxide_aqi_value=$(echo "scale=3; (49/118) * ($sulphur_dioxide_ppb - 186) + 151" | bc -l)
	elif (($(echo "$sulphur_dioxide_ppb < 605" | bc -l))); then
		sulphur_dioxide_aqi_value=$(echo "scale=3; (99/299) * ($sulphur_dioxide_ppb - 305) + 201" | bc -l)
	elif (($(echo "$sulphur_dioxide_ppb < 805" | bc -l))); then
		sulphur_dioxide_aqi_value=$(echo "scale=3; (99/199) * ($sulphur_dioxide_ppb - 605) + 301" | bc -l)
	elif (($(echo "$sulphur_dioxide_ppb < 1005" | bc -l))); then
		sulphur_dioxide_aqi_value=$(echo "scale=3; (99/199) * ($sulphur_dioxide_ppb - 805) + 401" | bc -l)
	fi

	# PM2.5 (24-hr)
	if (($(echo "$fine_particle_matter < 12.1" | bc -l))); then
		fine_particle_aqi_value=$(echo "scale=3; (50/12) * $fine_particle_matter" | bc -l)
	elif (($(echo "$fine_particle_matter < 35.5" | bc -l))); then
		fine_particle_aqi_value=$(echo "scale=3; (49/23.3) * ($fine_particle_matter - 12.1) + 51" | bc -l)
	elif (($(echo "$fine_particle_matter < 55.5" | bc -l))); then
		fine_particle_aqi_value=$(echo "scale=3; (49/19.9) * ($fine_particle_matter - 35.5) + 101" | bc -l)
	elif (($(echo "$fine_particle_matter < 150.5" | bc -l))); then
		fine_particle_aqi_value=$(echo "scale=3; (49/94.9) * ($fine_particle_matter - 55.5) + 151" | bc -l)
	elif (($(echo "$fine_particle_matter < 250.5" | bc -l))); then
		fine_particle_aqi_value=$(echo "scale=3; (99/99.9) * ($fine_particle_matter - 150.5) + 201" | bc -l)
	elif (($(echo "$fine_particle_matter < 350.5" | bc -l))); then
		fine_particle_aqi_value=$(echo "scale=3; (99/99.9) * ($fine_particle_matter - 250.5) + 301" | bc -l)
	elif (($(echo "$fine_particle_matter < 500.5" | bc -l))); then
		fine_particle_aqi_value=$(echo "scale=3; (99/149.9) * ($fine_particle_matter - 350.5) + 401" | bc -l)
	fi

	# PM10 (24-hr)
	if (($(echo "$coarse_particulate_matter < 55" | bc -l))); then
		coarse_particulate_aqi_value=$(echo "scale=3; (50/54) * $coarse_particulate_matter" | bc -l)
	elif (($(echo "$coarse_particulate_matter < 155" | bc -l))); then
		coarse_particulate_aqi_value=$(echo "scale=3; (49/99) * ($coarse_particulate_matter - 55) + 51" | bc -l)
	elif (($(echo "$coarse_particulate_matter < 255" | bc -l))); then
		coarse_particulate_aqi_value=$(echo "scale=3; (49/99) * ($coarse_particulate_matter - 155) + 101" | bc -l)
	elif (($(echo "$coarse_particulate_matter < 355" | bc -l))); then
		coarse_particulate_aqi_value=$(echo "scale=3; (49/99) * ($coarse_particulate_matter - 255) + 151" | bc -l)
	elif (($(echo "$coarse_particulate_matter < 425" | bc -l))); then
		coarse_particulate_aqi_value=$(echo "scale=3; (99/69) * ($coarse_particulate_matter - 355) + 201" | bc -l)
	elif (($(echo "$coarse_particulate_matter < 505" | bc -l))); then
		coarse_particulate_aqi_value=$(echo "scale=3; (99/79) * ($coarse_particulate_matter - 425) + 301" | bc -l)
	elif (($(echo "$coarse_particulate_matter < 605" | bc -l))); then
		coarse_particulate_aqi_value=$(echo "scale=3; (99/99) * ($coarse_particulate_matter - 505) + 401" | bc -l)
	fi

	aqi_value=$(__get_aqi_max "$carbon_monoxide_aqi_value" "$nitrogen_dioxide_aqi_value" "$ozone_aqi_value" "$sulphur_dioxide_aqi_value" "$fine_particle_aqi_value" "$coarse_particulate_aqi_value")
	# aqi_value=150
	IFS=' ' read -r aqi_color aqi_symbol <<<"$(__get_aqi_level_color_symbol "$aqi_value")"
	rounded_aqi=$(printf '%.*f\n' 0 "$aqi_value")

	echo "${rounded_aqi} AQI ${aqi_symbol}" "${aqi_color}" | tee "${tmp_file}"
}

__convert_uqgm3_ppm() {
	local uqm3=$1

	ppm=$(echo "scale=3; $uqm3 / 1000" | bc)

	echo "$ppm"
}

__convert_uqgm3_ppb() {
	local uqm3=$1
	local molecular_weight=$2

	ppb=$(echo "scale=3; ($uqm3 * 24.45) / $molecular_weight" | bc)

	echo "$ppb"
}

__get_aqi_max() {
	local n1=$1
	local n2=$2
	local n3=$3
	local n4=$4
	local n5=$5
	local n6=$6

	max=$n1

	if (($(echo "$n2 > $max" | bc -l))); then
		max=$n2
	fi

	if (($(echo "$n3 > $max" | bc -l))); then
		max=$n3
	fi

	if (($(echo "$n4 > $max" | bc -l))); then
		max=$n4
	fi

	if (($(echo "$n5 > $max" | bc -l))); then
		max=$n5
	fi

	if (($(echo "$n6 > $max" | bc -l))); then
		max=$n6
	fi

	echo "$max"
}

__get_aqi_level_color_symbol() {
	local aqi_value=$1

	if (($(echo "$aqi_value < 51" | bc -l))); then
		# aqi_level="Good"
		aqi_color="#8da101" # Green
		aqi_symbol="😊"
	elif (($(echo "$aqi_value < 101" | bc -l))); then
		# aqi_level="Moderate"
		aqi_color="#dfa000" # Yellow
		aqi_symbol="😐"
	elif (($(echo "$aqi_value < 151" | bc -l))); then
		# aqi_level="Unhealthy for sensitive groups"
		aqi_color="#f57d26" # Orange
		aqi_symbol="🙁"
	elif (($(echo "$aqi_value < 201" | bc -l))); then
		# aqi_level="Unhealthy"
		aqi_color="#f85552" # Red
		aqi_symbol="😷"
	elif (($(echo "$aqi_value < 301" | bc -l))); then
		# aqi_level="Very unhealthy"
		aqi_color="#df69ba" # Purple
		aqi_symbol="😨"
	elif (($(echo "$aqi_value < 501" | bc -l))); then
		# aqi_level="Hazardous"
		aqi_color="#883A26" # Maroon
		aqi_symbol="🛑"
	elif (($(echo "$aqi_value < 1001" | bc -l))); then
		# aqi_level="Very Hazardous"
		aqi_color="#66401a" # Brown
		aqi_symbol="💀"
	fi

	echo "$aqi_color $aqi_symbol"
}

__read_tmp_file() {
	if [ ! -f "$tmp_file" ]; then
		return
	fi
	cat "${tmp_file}"
	exit
}
