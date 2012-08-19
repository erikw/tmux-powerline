#/usr/bin/env bash
# Print the current working directory (max 40+3 characters).

segment_cwd=$(dirname $0)
source "$segment_cwd/../lib.sh"

echo $(get_tmux_cwd | sed -e "s|${HOME}|~|" -e 's/^~$/~\//' -e 's/\(.\{40\}\).*$/\1.../')
