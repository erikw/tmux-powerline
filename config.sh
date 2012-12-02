#!/usr/bin/env sh
# Cofigurations for tmux-powerline.

if [ -z "$DEBUG_MODE" ]; then
	# Disable debug mode by default
	export DEBUG_MODE="false"
fi

# You platform \in {linux,mac}.
if [ -z "$PLATFORM" ]; then
	platform=$(uname | tr '[:upper:]' '[:lower:]')
	case "$platform" in
		linux)
			# Well, nothing to do.
			;;
		darwin)
			platform="mac"
			;;
		*bsd)
			platform="bsd"
			;;
		*)
			echo "Unknown platform \"${platform}\"" &1>&2
	esac
	export PLATFORM="$platform"

fi

if [ -z "$USE_PATCHED_FONT" ]; then
	# Useage of patched font for symbols. true or false.
	export USE_PATCHED_FONT="true"
fi
