#!/usr/bin/env bash
#Print the status-left for tmux.
#
# The powerline root directory.
cwd=$(dirname $0)

# Source global configurations.
source "${cwd}/config.sh"

# Source lib functions.
source "${cwd}/lib.sh"

segments_path="${cwd}/${segments_dir}"

# Mute this statusbar?
mute_status_check "left"

# Segments

declare -A tmux_session_info
tmux_session_info+=(["script"]="${segments_path}/tmux_session_info.sh")
tmux_session_info+=(["foreground"]="colour22")
tmux_session_info+=(["background"]="colour148")
tmux_session_info+=(["separator"]="${separator_right_bold}")
#tmux_session_info+=(["separator_fg"]="default")
register_segment "tmux_session_info"

declare -A whoami
whoami+=(["script"]="${segments_path}/whoami.sh")
whoami+=(["foreground"]="colour250")
whoami+=(["background"]="colour242")
whoami+=(["separator"]="${separator_right_bold}")
register_segment "whoami"

declare -A hostname
hostname+=(["script"]="${segments_path}/hostname.sh")
hostname+=(["foreground"]="colour252")
hostname+=(["background"]="colour242")
hostname+=(["separator"]="${separator_right_thin}")
hostname+=(["separator_fg"]="colour250")
register_segment "hostname"

declare -A lan_ip
lan_ip+=(["script"]="${segments_path}/lan_ip.sh")
lan_ip+=(["foreground"]="colour253")
lan_ip+=(["background"]="colour242")
lan_ip+=(["separator"]="${separator_right_thin}")
lan_ip+=(["separator_fg"]="colour250")
register_segment "lan_ip"

declare -A wan_ip
wan_ip+=(["script"]="${segments_path}/wan_ip.sh")
wan_ip+=(["foreground"]="colour15")
wan_ip+=(["background"]="colour242")
wan_ip+=(["separator"]="${separator_right_thin}")
wan_ip+=(["separator_fg"]="white")
wan_ip+=(["separator_bg"]="black")
register_segment "wan_ip"

declare -A vcs_branch
vcs_branch+=(["script"]="${segments_path}/vcs_branch.sh")
vcs_branch+=(["foreground"]="colour15")
vcs_branch+=(["background"]="colour237")
vcs_branch+=(["separator"]="${separator_right_bold}")
#register_segment "vcs_branch"

# Print the status line in the order of registration above.
print_status_line_left

exit 0
