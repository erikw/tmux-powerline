#!/bin/sh
# Battery status for Macintosh machines. Borrowed from https://github.com/Meldanya/dotfiles/blob/master/tmux/power.sh
/usr/sbin/ioreg -l | awk 'BEGIN{a=0;b=0}
$0 ~ "MaxCapacity" {a=$5;next}
$0 ~ "CurrentCapacity" {b=$5;nextfile}
END{printf("%d%%", b/a * 100)}'
