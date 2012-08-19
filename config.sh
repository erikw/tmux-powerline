#!/bin/sh
# Cofigurations for tmux-powerline.

PLATFORM="mac"
USE_PATCHED_FONT="true"

if [ -z "$PLATFORM" ]; then
	# You platform \in {linux,bsd,mac
	export PLATFORM=
fi

if [ -z "$USE_PATCHED_FONT" ]; then
	# Useage of patched font for symbols. true or false.
	export USE_PATCHED_FONT="true"
fi

source ~/.zshrc
source ~/.oh-my-zsh/custom/api_stuff.zsh

