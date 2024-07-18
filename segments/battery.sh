# shellcheck shell=bash
# LICENSE This code is not under the same license as the rest of the project as it's "stolen". It's cloned from https://github.com/richoH/dotfiles/blob/master/bin/battery and just some modifications are done so it works for my laptop. Check that URL for more recent versions.

TMUX_POWERLINE_SEG_BATTERY_TYPE_DEFAULT="percentage"
TMUX_POWERLINE_SEG_BATTERY_NUM_BATTERIES_DEFAULT=5

BATTERY_FULL="󱊣"
BATTERY_MED="󱊢"
BATTERY_EMPTY="󱊡"
BATTERY_CHARGE="󰂄"
ADAPTER="󰚥"
BATTERY_CUTE_FULL=""
BATTERY_CUTE_EMPTY="♥"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# How to display battery remaining. Can be {percentage, cute}.
export TMUX_POWERLINE_SEG_BATTERY_TYPE="${TMUX_POWERLINE_SEG_BATTERY_TYPE_DEFAULT}"
# How may hearts to show if cute indicators are used.
export TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS="${TMUX_POWERLINE_SEG_BATTERY_NUM_BATTERIES_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	if shell_is_osx; then
		battery_status=$(__battery_osx)
		battery_icon=$(__battery_icon_osx "$battery_status")
	else
		battery_status=$(__battery_linux)
		battery_icon=$(__battery_icon_linux "$battery_status")
	fi
	if [ -z "$battery_status" ]; then
		echo "$ADAPTER "
		return
	fi

	case "$TMUX_POWERLINE_SEG_BATTERY_TYPE" in
	"percentage")
		output="$battery_icon ${battery_status}%"
		;;
	"cute")
		output=$(__cutinate "$battery_status")
		# only show charge icon to keep it simple
		if [ "$battery_icon" == "$BATTERY_CHARGE" ]; then
			output="$battery_icon $output"
		fi
		;;
	esac
	if [ -n "$output" ]; then
		echo "$output"
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_BATTERY_TYPE" ]; then
		export TMUX_POWERLINE_SEG_BATTERY_TYPE="${TMUX_POWERLINE_SEG_BATTERY_TYPE_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS" ]; then
		export TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS="${TMUX_POWERLINE_SEG_BATTERY_NUM_BATTERIES_DEFAULT}"
	fi
}

__battery_osx() {
	ioreg -c AppleSmartBattery -w0 |
		grep -o '"[^"]*" = [^ ]*' |
		sed -e 's/= //g' -e 's/"//g' |
		sort |
		while read -r key value; do
			case $key in
			"MaxCapacity")
				export maxcap=$value
				;;
			"CurrentCapacity")
				export curcap=$value
				;;
			"ExternalConnected")
				export extconnect=$value
				;;
			"FullyCharged")
				export fully_charged=$value
				;;
			esac

			# We've gotten all the values we care about
			if [[ -n $maxcap && -n $curcap && -n $extconnect && -n $fully_charged ]]; then
				break
			fi
		done
	charge=$(pmset -g batt | grep -o "[0-9][0-9]*\%" | rev | cut -c 2- | rev)
	if [[ ("$fully_charged" == "Yes" || $charge -eq 100) && $extconnect == "Yes" ]]; then
		return
	fi
	echo "$charge"
}

__battery_icon_osx() {
	charge=$1
	if [[ -n $charge ]]; then
		return
	fi

	ioreg -c AppleSmartBattery -w0 |
		grep -o '"[^"]*" = [^ ]*' |
		sed -e 's/= //g' -e 's/"//g' |
		sort |
		while read -r key value; do
			case $key in
			"MaxCapacity")
				export maxcap=$value
				;;
			"CurrentCapacity")
				export curcap=$value
				;;
			"ExternalConnected")
				export extconnect=$value
				;;
			"FullyCharged")
				export fully_charged=$value
				;;
			esac
			if [[ -n $maxcap && -n $curcap && -n $extconnect && -n $fully_charged ]]; then
				break
			fi
		done

	if [[ "$extconnect" == "Yes" ]]; then
		echo "$BATTERY_CHARGE"
	elif [[ $charge -lt 50 ]]; then
		echo -n "#[fg=#ff0000]"
		echo "$BATTERY_EMPTY"
	elif [[ $charge -lt 80 ]]; then
		echo "$BATTERY_MED"
	else
		echo "$BATTERY_FULL"
	fi
}

__battery_icon_linux() {
	perc=$1
	case "$SHELL_PLATFORM" in
	"linux")
		BATSTATUS=$(cat /sys/class/power_supply/battery/status)
		if [ "$BATSTATUS" == "Charging" ]; then
			icon="$BATTERY_CHARGE"
		elif [[ $perc -lt 50 ]]; then
			icon="#[fg=#ff0000]$BATTERY_EMPTY"
		elif [[ $perc -lt 80 ]]; then
			icon="$BATTERY_MED"
		else
			icon="$BATTERY_FULL"
		fi
		echo "$icon"
		;;
	esac
}

__battery_linux() {
	case "$SHELL_PLATFORM" in
	"linux")
		BATPATH=/sys/class/power_supply/BAT0
		if [ ! -d $BATPATH ]; then
			BATPATH=/sys/class/power_supply/BAT1
		fi
		if [ ! -d $BATPATH ]; then
			BATPATH=/sys/class/power_supply/battery
		fi
		BAT_FULL=$BATPATH/charge_full
		if [ ! -r $BAT_FULL ]; then
			BAT_FULL=$BATPATH/energy_full
		fi
		# WSL reports battery as a percentage already
		if [ ! -r $BAT_FULL ]; then
			BAT_FULL=100
		fi
		BAT_NOW=$BATPATH/charge_now
		if [ ! -r $BAT_NOW ]; then
			BAT_NOW=$BATPATH/energy_now
		fi
		if [ ! -r $BAT_NOW ]; then
			BAT_NOW=$BATPATH/capacity
		fi
		__linux_get_bat
		;;
	"bsd")
		__freebsd_get_bat
		;;
	esac
}

__cutinate() {
	perc=$1
	inc=$((100 / TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS))

	for _unused in $(seq "$TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS"); do
		if [ "$perc" -lt 99 ]; then
			echo -n $BATTERY_CUTE_EMPTY
		else
			echo -n $BATTERY_CUTE_FULL
		fi
		perc=$((perc + inc))
	done
}

__linux_get_bat() {
	if [ "$BAT_FULL" -eq 100 ]; then
		bf=$BAT_FULL
	else
		bf=$(cat "$BAT_FULL")
	fi
	bn=$(cat "$BAT_NOW")
	if [ "$bn" -gt "$bf" ]; then
		bn=$bf
	fi
	echo "$((100 * bn / bf))"
}

__freebsd_get_bat() {
	sysctl -n hw.acpi.battery.life
}
