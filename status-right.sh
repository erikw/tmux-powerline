# TODO try: Power: #(acpi -V | awk \'NR==1 {print $4}\' | cut -d \",\" -f1)
#!/bin/sh
# This script prints a string will be evaluated for text attributes (but not shell commands) by tmux. It consists of a bunch of addins that are simple shell scripts/programs that output the information to show. For each addin the desired foreground and background color can be specified as well as what separator to use. The script the glues together these addins dynamically so that if one script suddenly does not output anything (= nothing should be shown) the separator colors will be nicely handled.

# Enter the script directory so we easily can use the other scripts.
cd "$(dirname $0)"

# Source lib functions.
. lib.sh

# Addins

declare -A mail_count
mail_count+=(["script"]="${addins_path}/maildir_inbox_count.sh")
mail_count+=(["foreground"]="white")
mail_count+=(["background"]="red")
mail_count+=(["separator"]="${separator_left_bold}")
register_addin "mail_count"

declare -A mpd_np
mpd_np+=(["script"]="${addins_path}/mpd_np.sh")
mpd_np+=(["foreground"]="colour37")
mpd_np+=(["background"]="colour234")
mpd_np+=(["separator"]="${separator_left_bold}")
register_addin "mpd_np"

declare -A load
load+=(["script"]="${addins_path}/load.sh")
load+=(["foreground"]="colour167")
load+=(["background"]="colour237")
load+=(["separator"]="${separator_left_bold}")
register_addin "load"

declare -A date_day
date_day+=(["script"]="${addins_path}/date_day.sh")
date_day+=(["foreground"]="colour136")
date_day+=(["background"]="colour235")
date_day+=(["separator"]="${separator_left_bold}")
register_addin "date_day"

declare -A date_full
date_full+=(["script"]="${addins_path}/date_full.sh")
date_full+=(["foreground"]="colour136")
date_full+=(["background"]="colour235")
date_full+=(["separator"]="${separator_left_thin}")
date_full+=(["separator_fg"]="default")
register_addin "date_full"

declare -A time
time+=(["script"]="${addins_path}/time.sh")
time+=(["foreground"]="colour136")
time+=(["background"]="colour235")
time+=(["separator"]="${separator_left_thin}")
time+=(["separator_fg"]="default")
register_addin "time"

# Print the status line in the order of registration above.
print_status_line_left

exit 0
