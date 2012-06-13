#!/bin/sh
# Prints the uptime.
uptime  | grep -Pzo "(?<=up  )[^,]*"
