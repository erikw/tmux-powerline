# shellcheck shell=bash

# Echoes the value of the given section and key of in the INI file. When the
# section is omitted, the key is looked up in the unnamed section.
#
# Usage: `tp_get_ini_value <file_path> [<section>] <key>`
#
# This function supports the Python-style INI file format, where sections are
# denoted by `[section]` and key-value pairs are in the form `key=value` or
# `key: value`.
#
# See https://docs.python.org/3/library/configparser.html#supported-ini-file-structure for details.
#
# Limitations:
# - Keys are case-sensitive.
# - Multiline values are not supported.
tp_get_ini_value() {
	local ini_file="$1" section='' key
	case "$#" in
		2) key="$2";;
		3) section="$2" key="$3";;
		*) return 2;;
	esac
	[ -f "$ini_file" ] || return 1
	awk -v section="$section" -v key="$key" '
		BEGIN { in_section = (section == "") }
		/^[[:blank:]]*[#;]/ { next }
		/^[[:blank:]]*\[.*][[:blank:]]*$/ {
			# parse the section name
			name = $0
			gsub(/^[[:blank:]]*\[|][[:blank:]]*$/, "", name)
			in_section = (name == section)
			next
		}
		!in_section { next }
		{
			# parse the key-value pair in the specified section
			pos = index($0, "=")
			colon = index($0, ":")
			if (pos == 0 || (0 < colon && colon < pos)) pos = colon
			if (pos == 0) next
			k = substr($0, 1, pos - 1)
			gsub(/^[[:blank:]]+|[[:blank:]]+$/, "", k)
			if (k == key) {
				v = substr($0, pos + 1)
				gsub(/^[[:blank:]]+|[[:blank:]]+$/, "", v)
				print v
				exit
			}
		}
	' "$ini_file"
}
