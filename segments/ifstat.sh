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
			formate=$(echo "${formate} ${type} ⇊ %.2f ⇈ %.2f")
			holder=$(echo "${holder},\$$((index)),\$$((index+1))")
		fi
		index=$((index+2))
	done
	if [ -n "${formate}" ]; then
		echo $(echo "${flow_data#,}" | awk -F"," "{printf(\"${formate}\"${holder})}")
	fi
	return 0
}
