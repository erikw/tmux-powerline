# Prints the uptime.

run_segment() {
	uptime | grep -PZo "(?<=up )[^,]*"
	return 0
}
