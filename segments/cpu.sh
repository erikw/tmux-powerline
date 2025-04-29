# shellcheck shell=bash
# Prints the CPU usage: user% sys% idle.

run_segment() {
	if shell_is_linux; then
		cpu_line=$(top -b -n 1 | grep "Cpu(s)")
		# cpu_line example: %Cpu(s): 13.3 us, 13.3 sy,  0.0 ni, 73.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
		cpu_user=$(echo "$cpu_line" | grep -o "[0-9]\+\(.[0-9]\+\)\? *us\(er\)\?" | awk '{ print $1 }')
		cpu_system=$(echo "$cpu_line" | grep -o "[0-9]\+\(.[0-9]\+\)\? *sys\?" | awk '{ print $1 }')
		cpu_idle=$(echo "$cpu_line" | grep -o "[0-9]\+\(.[0-9]\+\)\? *id\(le\)\?" | awk '{ print $1 }')
	elif shell_is_macos; then
		cpus_line=$(top -e -l 1 | grep "CPU usage:" | sed 's/CPU usage: //')
		cpu_user=$(echo "$cpus_line" | awk '{print $1}' | sed 's/%//')
		cpu_system=$(echo "$cpus_line" | awk '{print $3}' | sed 's/%//')
		cpu_idle=$(echo "$cpus_line" | awk '{print $5}' | sed 's/%//')
	fi

	if [ -n "$cpu_user" ] && [ -n "$cpu_system" ] && [ -n "$cpu_idle" ]; then
		printf "%5.1f, %5.1f, %5.1f" "${cpu_user}" "${cpu_system}" "${cpu_idle}"
		return 0
	else
		return 1
	fi
}
