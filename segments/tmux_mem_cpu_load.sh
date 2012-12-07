#!/usr/bin/env sh
# Print out Memory, cpu and load using https://github.com/thewtex/tmux-mem-cpu-load


type tmux-mem-cpu-load >/dev/null 2>&1
if [ "$?" -ne 0 ]; then
	return
fi

stats=$(tmux-mem-cpu-load)
if [ -n "$stats" ]; then
	echo "$stats";
fi
