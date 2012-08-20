#!/usr/bin/env sh
# Prints the CPU usage: user% sys% idle.

cpu_line=$(top -b -n 1 | grep "Cpu(s)")

cpu_user=$(echo "$cpu_line" | grep -Po "(\d+(.\d+)?)(?=%?\s?(us(er)?))")
cpu_system=$(echo "$cpu_line" | grep -Po "(\d+(.\d+)?)(?=%?\s?(sys?))")
cpu_idle=$(echo "$cpu_line" | grep -Po "(\d+(.\d+)?)(?=%?\s?(id(le)?))")

if [ -n "$cpu_user" ] && [ -n "$cpu_system" ] && [ -n "$cpu_idle" ]; then
	echo "${cpu_user}, ${cpu_system}, ${cpu_idle}"
	exit 0
else
	exit 1
fi
