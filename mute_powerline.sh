#!/usr/bin/env bash

cwd="$(dirname $0)"
source "${cwd}/config/paths.sh"
source "${cwd}/lib/muting.sh"
source "${cwd}/lib/arg_processing.sh"

side="$1"
check_arg_side "$side"
toggle_powerline_mute_status "$side"
