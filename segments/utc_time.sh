# Prints the current time in UTC.

run_segment() {
	date --utc +"%H:%M"
	return 0
}
