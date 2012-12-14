#!/usr/bin/env bash

source "$(dirname $0)/config/paths.sh"
source "$(dirname $0)/lib/muting.sh"

side=$1
toggle_powerline_mute_status $side
