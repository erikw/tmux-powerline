# Prints the uptime.

run_segment() {
    uptime | sed 's/.*up \([^,]*\), .*/\1/'
    return 0
}
