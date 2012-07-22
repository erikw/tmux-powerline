#!/usr/bin/env sh
# Prints the uptime.
uptime | grep --color=never -PZo "(?<=up )[^,]*"
