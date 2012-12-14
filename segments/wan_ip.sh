#!/usr/bin/env bash
# Prints the WAN IP address. The result is cached and updated according to $update_period.

tmp_file="${TMUX_POWERLINE_TEMPORARY_DIRECTORY}/wan_ip.txt"
wan_ip=""

if [ -f "$tmp_file" ]; then
  if shell_is_osx; then
    last_update=$(stat -f "%m" ${tmp_file})
  else
    last_update=$(stat -c "%Y" ${tmp_file})
  fi

  time_now=$(date +%s)
  update_period=900
  up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)

  if [ "$up_to_date" -eq 1 ]; then
    wan_ip=$(cat ${tmp_file})
  fi
fi

if [ -z "$wan_ip" ]; then
  wan_ip=$(curl --max-time 2 -s http://whatismyip.akamai.com/)

  if [ "$?" -eq "0" ]; then
    echo "${wan_ip}" > $tmp_file
  elif [ -f "${tmp_file}" ]; then
    wan_ip=$(cat "$tmp_file")
  fi
fi

if [ -n "$wan_ip" ]; then
  echo "ⓦ ${wan_ip}"
fi

exit 0
