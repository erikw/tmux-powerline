# Prints the uptime.


if shell_is_bsd; then
    TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT="/usr/local/bin/grep"
else
    TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT="grep"
fi

__process_settings() {
    if [ -z "$TMUX_POWERLINE_SEG_UPTIME_GREP" ]; then
        export TMUX_POWERLINE_SEG_UPTIME_GREP="${TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT}"
    fi
}

generate_segmentrc() {
    read -d '' rccontents  << EORC
# Name of GNU grep binary if in PATH, or path to it.
export TMUX_POWERLINE_SEG_UPTIME_GREP="${TMUX_POWERLINE_SEG_UPTIME_GREP_DEFAULT}"
EORC
    echo "$rccontents"
}

run_segment() {
    __process_settings
    # Assume latest grep is in PATH
    gnugrep="${TMUX_POWERLINE_SEG_UPTIME_GREP}"
    uptime | $gnugrep -PZo "(?<=up )[^,]*"
    return 0
}
