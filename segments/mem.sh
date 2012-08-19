#!/usr/bin/env sh
# Prints the mem usage

top -l 1 | grep "PhysMem" | awk '{ print $10 }'

exit 0

