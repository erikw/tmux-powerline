# Print the current working directory (trimmed to max length).
# NOTE The trimming code's stolen from the web. Courtesy to who ever wrote it.

max_len=40			# Max output length.

run_segment() {
	# Truncate from the left.
	tcwd=$(get_tmux_cwd)
	trunc_symbol=".."
	dir=${tcwd##*/}
	max_len=$(( ( max_len < ${#dir} ) ? ${#dir} : max_len ))
	ttcwd=${tcwd/#$HOME/\~}
	pwdoffset=$(( ${#ttcwd} - max_len ))
	if [ ${pwdoffset} -gt "0" ]; then
		ttcwd=${ttcwd:$pwdoffset:$max_len}
		ttcwd=${trunc_symbol}/${ttcwd#*/}
	fi
	echo "$ttcwd"
	return 0
}
