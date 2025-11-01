# shellcheck shell=bash

# based on https://github.com/thewtex/tmux-mem-cpu-load
# shellcheck disable=SC2001
__tp_mem_used_info() {
	if tp_shell_is_macos; then
		local stats
		local bytes_per_page
		local free_pages
		local external_pages
		local mem_total_bytes
		local mem_used_bytes

		stats=$(vm_stat | tr '\n' ' ')
		bytes_per_page=$(echo "$stats" | sed -e 's/.*page size of \([0-9]*\).*/\1/')
		mem_total_bytes=$(sysctl hw.memsize | sed -e 's/^hw.memsize: \([0-9*]\)/\1/')
		free_pages=$(echo "$stats" | sed -e 's/.*Pages free: *\([0-9]*\).*/\1/')
		external_pages=$(echo "$stats" | sed -e 's/.*File-backed pages: *\([0-9]*\).*/\1/')
		mem_used_bytes=$(echo "$mem_total_bytes - ($free_pages + $external_pages) * $bytes_per_page" | bc -l)

		echo "$mem_used_bytes" "$mem_total_bytes"

	elif tp_shell_is_linux; then
		local meminfo
		local mem_total
		local mem_total_bytes
		local mem_free
		local shmem
		local buffers
		local cached
		local s_reclaimable
		local mem_used_bytes

		meminfo=$(tr '\n' ' ' < /proc/meminfo)
		mem_total=$(echo "$meminfo" | sed -e 's/^MemTotal: *\([0-9]*\).*/\1/')
		mem_total_bytes=$(echo "$mem_total * 1024" | bc -l)
		mem_free=$(echo "$meminfo" | sed -e 's/.* MemFree: *\([0-9]*\).*/\1/')
		shmem=$(echo "$meminfo" | sed -e 's/.* Shmem: *\([0-9]*\).*/\1/')
		buffers=$(echo "$meminfo" | sed -e 's/.* Buffers: *\([0-9]*\).*/\1/')
		cached=$(echo "$meminfo" | sed -e 's/.* Cached: *\([0-9]*\).*/\1/')
		s_reclaimable=$(echo "$meminfo" | sed -e 's/.* SReclaimable: *\([0-9]*\).*/\1/')
		mem_used_bytes=$(echo "($mem_total - $mem_free + $shmem - $buffers - $cached - $s_reclaimable) * 1024" | bc -l)

		echo "$mem_used_bytes" "$mem_total_bytes"
	fi
};

tp_mem_used_gigabytes() {
	read -r mem_used_bytes mem_total_bytes < <(__tp_mem_used_info)
	tp_round "$(echo "$mem_used_bytes / 1073741824" | bc -l)" 2
}

tp_mem_used_megabytes() {
	read -r mem_used_bytes mem_total_bytes < <(__tp_mem_used_info)
	tp_round "$(echo "$mem_used_bytes / 1048576" | bc -l)" 0
}

tp_mem_used_percentage_at_least() {
	local threshold_percentage="$1"
	read -r mem_used_bytes mem_total_bytes < <(__tp_mem_used_info)
	echo "($mem_used_bytes / $mem_total_bytes) * 100 >= $threshold_percentage" | bc -l
}

