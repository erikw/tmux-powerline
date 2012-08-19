#!/usr/bin/env bash
# This script prints a string will be evaluated for text attributes (but not shell commands) by tmux. It consists of a bunch of segments that are simple shell scripts/programs that output the information to show. For each segment the desired foreground and background color can be specified as well as what separator to use. The script the glues together these segments dynamically so that if one script suddenly does not output anything (= nothing should be shown) the separator colors will be nicely handled.

# The powerline root directory.
# cwd=$(dirname $0)
cwd="/Users/gxl/work/gxl/tmux-powerline"

# Source global configurations.
source "${cwd}/config.sh"

# Source lib functions.
source "${cwd}/lib.sh"

segments_path="${cwd}/${segments_dir}"

# Segment
# Comment/uncomment the register function call to enable or disable a segment.

# declare -A mail_count
# mail_count+=(["script"]="${segments_path}/maildir_count.sh")
# mail_count+=(["script"]="${segments_path}/apple_mail_count.sh")
# mail_count+=(["foreground"]="white")
# mail_count+=(["background"]="red")
# mail_count+=(["separator"]="${separator_left_bold}")
# register_segment "mail_count"

# declare -A now_playing
# if [ "$PLATFORM" == "linux" ]; then
	# now_playing+=(["script"]="${segments_path}/np_mpd.sh")
	# #now_playing+=(["script"]="${segments_path}/np_spotify_linux_wine.sh")
	# #now_playing+=(["script"]="${segments_path}/np_spotify_linux_native.sh")
	# #now_playing+=(["script"]="${segments_path}/np_rhythmbox.sh")
	# #now_playing+=(["script"]="${segments_path}/np_banshee.sh")
	# #now_playing+=(["script"]="${segments_path}/np_audacious.sh")
# elif [ "$PLATFORM" == "mac" ]; then
	# now_playing+=(["script"]="${segments_path}/np_itunes_mac.sh")
# fi
# if [[ ${now_playing["script"]} ]]; then
	# now_playing+=(["foreground"]="colour37")
	# now_playing+=(["background"]="colour234")
	# now_playing+=(["separator"]="${separator_left_bold}")
	# register_segment "now_playing"
# fi

declare -A mem
mem+=(["script"]="${segments_path}/mem.sh")
mem+=(["foreground"]="colour239")
mem+=(["background"]="default")
mem+=(["separator"]="${separator_left_bold}")
mem+=(["separator_fg"]="colour239")
register_segment "mem"

declare -A cpu
cpu+=(["script"]="${segments_path}/cpu.sh")
cpu+=(["foreground"]="colour239")
cpu+=(["background"]="default")
cpu+=(["separator"]="${separator_left_thin}")
cpu+=(["separator_fg"]="colour239")
register_segment "cpu"

declare -A load
load+=(["script"]="${segments_path}/load.sh")
load+=(["foreground"]="colour239")
load+=(["background"]="default")
load+=(["separator"]="${separator_left_thin}")
load+=(["separator_fg"]="colour239")
register_segment "load"

# declare -A battery
# if [ "$PLATFORM" == "mac" ]; then
	# battery+=(["script"]="${segments_path}/battery_mac.sh")
# else
	# battery+=(["script"]="${segments_path}/battery.sh")
# fi
# battery+=(["foreground"]="colour127")
# battery+=(["background"]="colour137")
# battery+=(["separator"]="${separator_left_bold}")
#register_segment "battery"

# declare -A weather
# weather+=(["script"]="${segments_path}/weather.sh")
# weather+=(["foreground"]="colour255")
# weather+=(["background"]="colour37")
# weather+=(["separator"]="${separator_left_bold}")
# register_segment "weather"

# declare -A xkb_layout
# if [ "$PLATFORM" == "linux" ]; then
# 	xkb_layout+=(["script"]="${segments_path}/xkb_layout.sh")
# 	xkb_layout+=(["foreground"]="colour117")
# 	xkb_layout+=(["background"]="colour125")
# 	xkb_layout+=(["separator"]="${separator_left_bold}
# fi
# register_segment "xkb_layout"

# declare -A date_day
# date_day+=(["foreground"]="colour136")
# date_day+=(["background"]="colour235")
# date_day+=(["separator"]="${separator_left_bold}")
# register_segment "date_day"

declare -A date_full
date_full+=(["script"]="${segments_path}/date_full.sh")
date_full+=(["foreground"]="colour233")
date_full+=(["background"]="colour239")
date_full+=(["separator"]="${separator_left_bold}")
date_full+=(["separator_fg"]="colour239")
register_segment "date_full"

declare -A time
time+=(["script"]="${segments_path}/time.sh")
time+=(["foreground"]="black")
time+=(["background"]="white")
time+=(["separator"]="${separator_left_bold}")
time+=(["separator_fg"]="white")
time+=(["separator_bg"]="colour239")
register_segment "time"

# Print the status line in the order of registration above.
print_status_line_right

exit 0
