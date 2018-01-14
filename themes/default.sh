# My Theme
# Changed after the default theme
# last edit: 9.12.2017 22:23

if patched_font_in_use; then
  TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
  TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
  TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
  TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
else
  TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
  TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
  TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
  TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
fi

TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-'235'}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-'235'}

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}


# Format: segment_name background_color foreground_color [non_default_separator]

if [ -z $TMUX_POWERLINE_LEFT_STATUS_SEGMENTS ]; then
  TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
  #"tmux_session_info 148 234" \
    #"hostname 33 0" \
    #"ifstat 30 255" \
    #"ifstat_sys 30 255" \
    #"lan_ip 235 131" \
    "wan_ip 236 131" \
    "vcs_modified 6 0" \
    "vcs_branch 234 131" \
   #"vcs_compare 60 255" \

    #"vcs_staged 64 255" \
    #"vcs_others 245 0" \
  )
fi

if [ -z $TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS ]; then
  TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
  #"earthquake 3 0" \
   "pwd 235 240" \
    #"macos_notification_count 29 255" \
    #"mailcount 9 255" \
    #"now_playing 234 37" \
    #"cpu 240 136" \
    #"load 237 167" \
    #"tmux_mem_cpu_load 234 136" \
    #"battery 137 127" \
    "weather 6 0" \
    #"rainbarf 0 ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
    #"xkb_layout 125 117" \
    #"date_day 235 136" \
    #"date 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
    "time 236 209" \
    #"utc_time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
    )
fi
