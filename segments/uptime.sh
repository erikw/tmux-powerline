#!/bin/sh
# Prints the uptime.
uptime  | grep -PZo "(?<=up  )[^,]*"
