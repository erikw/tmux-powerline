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
	if shell_is_macos; then
		battery_status=$(__battery_macos)
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

__battery_macos() {
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
	local total_full=0
	local total_now=0

	while read -r bat; do
		local full="$bat/charge_full"
		local now="$bat/charge_now"

		if [ ! -r "$full" ]; then
			full="$bat/energy_full"
		fi
		if [ ! -r "$now" ]; then
			now="$bat/energy_now"
		fi

		if [ -r "$full" ] && [ -r "$now" ]; then
			local bf
			local bn
			bf=$(cat "$full")
			bn=$(cat "$now")
			total_full=$((total_full + bf))
			total_now=$((total_now + bn))
		fi
	done <<<"$(grep -l "Battery" /sys/class/power_supply/*/type | sed -e 's,/type$,,')"

	if [ "$total_full" -gt 0 ]; then
		if [ "$total_now" -gt "$total_full" ]; then
			total_now=$total_full
		fi
		echo "$BATTERY_MED $((100 * total_now / total_full))"
	fi
}

__freebsd_get_bat() {
	echo "$BATTERY_MED $(sysctl -n hw.acpi.battery.life)"
}
