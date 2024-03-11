TMUX_POWERLINE_DIR_TEMPORARY="/tmp/tmux-powerline_${USER}"
air_temp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/temp_air_file.txt"

if [ -n "$air_temp_file" ] && [ -f "$air_temp_file" ]; then
    TMUX_POWERLINE_SEG_AIR_COLOR=$(awk '{print $NF}' "$air_temp_file")
fi

TMUX_POWERLINE_SEG_AIR_COLOR="${TMUX_POWERLINE_SEG_AIR_COLOR:-'37'}"
