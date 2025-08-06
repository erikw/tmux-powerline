#!/usr/bin/env bash
# Print tmux color palette.
# Idea from http://superuser.com/questions/285381/how-does-the-tmux-color-palette-work

for i in $(seq 0 8 255); do
	for j in $(seq "$i" $((i + 7))); do
		for _unused in $(seq 1 $((7 - ${#j}))); do
			echo -n " "
		done
		echo -en "\x1b[38;5;${j}mcolour${j}"
		[[ $((j % 8)) != 7 ]] && echo -n "    "
	done
	echo
done
