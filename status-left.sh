#!/usr/bin/env bash
#Print the status-left for tmux.
#
# The powerline root directory.
cwd=$(dirname $0)
cwd="/Users/gxl/work/gxl/tmux-powerline"

# Source global configurations.
source "${cwd}/config.sh"

# Source lib functions.
source "${cwd}/lib.sh"

segments_path="${cwd}/${segments_dir}"

# Segments

declare -A tmux_session_info
tmux_session_info+=(["script"]="${segments_path}/tmux_session_info.sh")
tmux_session_info+=(["foreground"]="colour234")
tmux_session_info+=(["background"]="colour148")
tmux_session_info+=(["separator"]="${separator_right_bold}")
# tmux_session_info+=(["separator_fg"]="default")
register_segment "tmux_session_info"

declare -A hostname
hostname+=(["script"]="${segments_path}/hostname.sh")
hostname+=(["foreground"]="default")
hostname+=(["background"]="colour24")
hostname+=(["separator"]="${separator_right_bold}")
register_segment "hostname"

# declare -A vcs_branch
# vcs_branch+=(["script"]="${segments_path}/vcs_branch.sh")
# vcs_branch+=(["foreground"]="colour88")
# vcs_branch+=(["background"]="colour29")
# vcs_branch+=(["separator"]="${separator_right_bold}")
# register_segment "vcs_branch"

# declare -A pwd
# pwd+=(["script"]="${segments_path}/pwd.sh")
# pwd+=(["foreground"]="colour211")
# pwd+=(["background"]="colour89")
# pwd+=(["separator"]="${separator_left_bold}")
# register_segment "pwd"

declare -A lan_ip
lan_ip+=(["script"]="${segments_path}/lan_ip.sh")
lan_ip+=(["foreground"]="colour239")
lan_ip+=(["background"]="default")
lan_ip+=(["separator"]="${separator_right_bold}")
register_segment "lan_ip"

declare -A wan_ip
wan_ip+=(["script"]="${segments_path}/wan_ip.sh")
wan_ip+=(["foreground"]="colour239")
wan_ip+=(["background"]="default")
wan_ip+=(["separator"]="${separator_right_thin}")
wan_ip+=(["separator_fg"]="colour239")
register_segment "wan_ip"

# Print the status line in the order of registration above.
print_status_line_left

exit 0
