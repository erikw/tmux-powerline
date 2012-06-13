#!/bin/sh
# Print the uptime.
uptime | cut -d "," -f 3- | cut -d ":" -f2

exit 0
