#!/bin/sh
# Cofigurations for tmux-powerline.

if [ -z "$PLATFORM" ]; then
	# You platform \in {linux,bsd,mac}.
	#export PLATFORM="linux"
	export PLATFORM="mac"
fi

if [ -z "$USE_PATCHED_FONT" ]; then
	# Useage of patched font for symbols. true or false.
	export USE_PATCHED_FONT="true"
fi
