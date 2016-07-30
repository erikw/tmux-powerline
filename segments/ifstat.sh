# Show network statistics for all active interfaces found.

run_segment() {
	type ifstat >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return 1
	fi

	sed="sed"
	type gsed >/dev/null 2>&1
	if [ "$?" -eq 0 ]; then
		sed="gsed"
	fi

	data=$(ifstat -z -S -q 1 1)
	interfaces=$(echo -e "${data}" | head -n 1)
	flow_data=$(echo -e "${data}" | tail -n 1 | ${sed} "s/\s\{1,\}/,/g")
	index=1
	for inf in ${interfaces}; do
		type=""
		case ${inf} in
			eth*) type="⎆"
				;;
			wlan*) type="☫"
				;;
			en*) type=" "
				;;
		esac
		if [ -n "${type}" ]; then
			format=$(echo "${format} ${type} ⇊ %5.01f ⇈ %5.01f")
			holder=$(echo "${holder},\$$((index)),\$$((index+1))")
		fi
		index=$((index+2))
	done
	if [ -n "${format}" ]; then
		echo $(echo "${flow_data#,}" | awk -F"," "{printf(\"${format}\"${holder})}")
	fi
	return 0
}
