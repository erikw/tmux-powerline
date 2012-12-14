#!/usr/bin/env bash

cwd="$(dirname $0)"
source "${cwd}/config/paths.sh"
source "${cwd}/lib/muting.sh"

side="$1"
toggle_powerline_mute_status "$side"
