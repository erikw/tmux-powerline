#!/usr/bin/env bash
# Print tmux color palette.
# Idea from http://superuser.com/questions/285381/how-does-the-tmux-color-palette-work

for i in $(seq 0 8 255); do
	for j in $(seq $i $(expr $i + 7)); do
		for k in $(seq 1 $(expr 7 - ${#j})); do
			printf " "
		done
		printf "\x1b[38;5;${j}mcolour${j}"
		[[ $(expr $j % 8) != 7 ]] && printf "    "
	done
	printf "\n"
done
