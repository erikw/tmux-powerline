# shellcheck shell=bash
# LICENSE This code is not under the same license as the rest of the project as it's "stolen". It's cloned from https://github.com/richoH/dotfiles/blob/master/bin/battery and just some modifications are done so it works for my laptop. Check that URL for more recent versions.

TMUX_POWERLINE_SEG_BATTERY_TYPE_DEFAULT="percentage"
TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS_DEFAULT=5

HEART_FULL="♥"
HEART_EMPTY="♡"
BATTERY_FULL="󱊣"
BATTERY_MED="󱊢"
BATTERY_EMPTY="󱊡"
BATTERY_CHARGE="󰂄"
ADAPTER="󰚥"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# How to display battery remaining. Can be {percentage, cute, hearts}.
export TMUX_POWERLINE_SEG_BATTERY_TYPE="${TMUX_POWERLINE_SEG_BATTERY_TYPE_DEFAULT}"
# How may hearts to show if cute indicators are used.
export TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS="${TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	if shell_is_osx; then
		battery_status=$(__battery_osx)
	else
		battery_status=$(__battery_linux)
	fi
	if [ -z "$battery_status" ]; then
		echo "$ADAPTER "
		return
	fi

	case "$TMUX_POWERLINE_SEG_BATTERY_TYPE" in
	"percentage")
		output="${battery_status}%"
		;;
	"cute")
		output=$(__cutinate "$battery_status")
		;;
	"hearts")
		output=$(__generate_hearts "${battery_status/* /}")
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
		export TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS="${TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS_DEFAULT}"
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
			if [[ -n $maxcap && -n $curcap && -n $extconnect ]]; then
				charge=$(pmset -g batt | grep -o "[0-9][0-9]*\%" | rev | cut -c 2- | rev)
				if [[ ("$fully_charged" == "Yes" || $charge -eq 100) && $extconnect == "Yes" ]]; then
					return
				fi
				if [[ "$extconnect" == "Yes" ]]; then
					echo "$BATTERY_CHARGE $charge"
				else
					if [[ $charge -lt 50 ]]; then
						echo -n "#[fg=#ff0000]"
						echo "$BATTERY_EMPTY $charge"
					elif [[ $charge -lt 80 ]]; then
						echo "$BATTERY_MED $charge"
					else
						echo "$BATTERY_FULL $charge"
					fi
				fi
				break
			fi
		done
}

__battery_linux() {
	case "$SHELL_PLATFORM" in
	"linux")
		BATPATH=/sys/class/power_supply/BAT0
		if [ ! -d $BATPATH ]; then
			BATPATH=/sys/class/power_supply/BAT1
		fi
		BAT_FULL=$BATPATH/charge_full
		if [ ! -r $BAT_FULL ]; then
			BAT_FULL=$BATPATH/energy_full
		fi
		BAT_NOW=$BATPATH/charge_now
		if [ ! -r $BAT_NOW ]; then
			BAT_NOW=$BATPATH/energy_now
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
			echo -n $BATTERY_EMPTY
		else
			echo -n $BATTERY_FULL
		fi
		echo -n " "
		perc=$((perc + inc))
	done
}

__generate_hearts() {
	perc=$1
	num_hearts=$TMUX_POWERLINE_SEG_BATTERY_NUM_HEARTS
	hearts_output=""

	for i in $(seq 1 "$num_hearts"); do
		if [ "$perc" -ge $((i * 100 / num_hearts)) ]; then
			hearts_output+="$HEART_FULL "
		else
			hearts_output+="$HEART_EMPTY "
		fi
	done
	echo "$hearts_output"
}

__linux_get_bat() {
	bf=$(cat "$BAT_FULL")
	bn=$(cat "$BAT_NOW")
	if [ "$bn" -gt "$bf" ]; then
		bn=$bf
	fi
	echo "$BATTERY_MED $((100 * bn / bf))"
}

__freebsd_get_bat() {
	echo "$BATTERY_MED $(sysctl -n hw.acpi.battery.life)"
}
