#!/bin/sh
#Print the status-left for tmux.
#
# Enter the script directory so we easily can use the other scripts.
cd "$(dirname $0)"

# Source lib functions.
. ./lib.sh

# Addins

declare -A tmux_session_info
tmux_session_info+=(["script"]="${addins_path}/tmux_session_info.sh")
tmux_session_info+=(["foreground"]="colour234")
tmux_session_info+=(["background"]="colour148")
tmux_session_info+=(["separator"]="${separator_right_bold}")
#tmux_session_info+=(["separator_fg"]="default")
register_addin "tmux_session_info"

declare -A hostname
hostname+=(["script"]="${addins_path}/hostname.sh")
hostname+=(["foreground"]="colour0")
hostname+=(["background"]="colour33")
hostname+=(["separator"]="${separator_right_bold}")
register_addin "hostname"

declare -A lan_ip
lan_ip+=(["script"]="${addins_path}/lan_ip.sh")
lan_ip+=(["foreground"]="colour255")
lan_ip+=(["background"]="colour24")
lan_ip+=(["separator"]="${separator_right_bold}")
register_addin "lan_ip"

declare -A wan_ip
wan_ip+=(["script"]="${addins_path}/wan_ip.sh")
wan_ip+=(["foreground"]="colour255")
wan_ip+=(["background"]="colour24")
wan_ip+=(["separator"]="${separator_right_thin}")
wan_ip+=(["separator_fg"]="white")
register_addin "wan_ip"

# Print the status line in the order of registration above.
print_status_line_left

exit 0
