# LICENSE This code is not under the same license as the rest of the project as it's "stolen". It's cloned from https://github.com/richoH/dotfiles/blob/master/bin/battery and just some modifications are done so it works for my laptop. Check that URL for more recent versions.

#CUTE_BATTERY_INDICATOR="true"

segment_path=$(dirname $0)
source "../config/shell.sh"

HEART_FULL=♥
HEART_EMPTY=♡
[ -z "$NUM_HEARTS" ] && NUM_HEARTS=5

run_segment() {
	if shell_is_osx; then
		battery_status=$(__battery_osx)
	else
		battery_status=$(__battery_linux)
	fi
	[ -z "$battery_status" ] && return

	if [ -n "$CUTE_BATTERY_INDICATOR" ]; then
		echo `__cutinate $battery_status`
	else
		echo "${HEART_FULL} ${battery_status}%"
	fi
}

__battery_osx() {
	ioreg -c AppleSmartBattery -w0 | \
		grep -o '"[^"]*" = [^ ]*' | \
		sed -e 's/= //g' -e 's/"//g' | \
		sort | \
		while read key value; do
			case $key in
				"MaxCapacity")
					export maxcap=$value;;
				"CurrentCapacity")
					export curcap=$value;;
				"ExternalConnected")
					export extconnect=$value;;
			esac
			if [[ -n $maxcap && -n $curcap && -n $extconnect ]]; then
				if [[ "$curcap" == "$maxcap" ]]; then
					return
				fi
				charge=$(( 100 * $curcap / $maxcap ))
				if [[ "$extconnect" == "Yes" ]]; then
					echo $HEART_FULL "$charge%"
				else
					if [[ $charge -lt 50 ]]; then
						echo -n "#[fg=red]"
					fi
					echo $HEART_EMPTY "$charge%"
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
				STATUS=$BATPATH/status
				BAT_FULL=$BATPATH/charge_full
				if [ ! -r $BAT_FULL ]; then
					BAT_FULL=$BATPATH/energy_full
				fi
				BAT_NOW=$BATPATH/charge_now
				if [ ! -r $BAT_NOW ]; then
					BAT_NOW=$BATPATH/energy_now
				fi

				if [ "$1" = `cat $STATUS` -o "$1" = "" ]; then
					__linux_get_bat
				fi
				;;
			"bsd")
				STATUS=`sysctl -n hw.acpi.battery.state`
				case $1 in
					"Discharging")
						if [ $STATUS -eq 1 ]; then
							__freebsd_get_bat
						fi
						;;
					"Charging")
						if [ $STATUS -eq 2 ]; then
							__freebsd_get_bat
						fi
						;;
					"")
						__freebsd_get_bat
						;;
				esac
				;;
		esac
	}

	__cutinate() {
		perc=$1
		inc=$(( 100 / $NUM_HEARTS))


		for i in `seq $NUM_HEARTS`; do
			if [ $perc -lt 100 ]; then
				echo $HEART_EMPTY
			else
				echo $HEART_FULL
			fi
			perc=$(( $perc + $inc ))
		done
	}

	__linux_get_bat() {
		bf=$(cat $BAT_FULL)
		bn=$(cat $BAT_NOW)
		echo $(( 100 * $bn / $bf ))
	}

	__freebsd_get_bat() {
		echo "$(sysctl -n hw.acpi.battery.life)"

	}
