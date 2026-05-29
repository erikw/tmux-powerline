#!/usr/bin/env bash

TMUX_POWERLINE_DIR_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TMUX_POWERLINE_DIR_HOME

# shellcheck source=lib/headers.sh
source "${TMUX_POWERLINE_DIR_HOME}/lib/headers.sh"

tp_process_settings

TP_DOCTOR_WARNINGS=""

tp_doctor_add_warning() {
	local warning="$1"

	if [ -n "$TP_DOCTOR_WARNINGS" ]; then
		TP_DOCTOR_WARNINGS="${TP_DOCTOR_WARNINGS}
${warning}"
	else
		TP_DOCTOR_WARNINGS="$warning"
	fi
}

tp_doctor_print_header() {
	printf '%s\n' 'tmux-powerline doctor'
	printf '%s\n' '===================='
}

tp_doctor_print_section() {
	printf '\n%s\n' "$1"
	printf '%s\n' '--------------------'
}

tp_doctor_print_value() {
	local label="$1"
	local value="$2"

	if [ -z "$value" ]; then
		value="(empty)"
	fi

	printf '  %-30s %s\n' "$label" "$value"
}

tp_doctor_var_value() {
	local name="$1"
	local value

	eval "value=\${$name-}"
	printf '%s' "$value"
}

tp_doctor_print_var() {
	local name="$1"
	local value

	value=$(tp_doctor_var_value "$name")
	tp_doctor_print_value "$name" "$value"
}

tp_doctor_print_path_var() {
	local name="$1"
	local value
	local description

	value=$(tp_doctor_var_value "$name")
	if [ -z "$value" ]; then
		description="(empty)"
	elif [ -d "$value" ]; then
		description="${value} [dir]"
	elif [ -f "$value" ]; then
		description="${value} [file]"
	elif [ -L "$value" ]; then
		description="${value} [symlink]"
	else
		description="${value} [missing]"
	fi

	tp_doctor_print_value "$name" "$description"
}

tp_doctor_print_array() {
	local name="$1"
	local value
	local i=0

	shift

	printf '  %s\n' "$name"

	if [ "$#" -eq 0 ]; then
		printf '    %s\n' '(empty)'
		return
	fi

	for value in "$@"; do
		printf '    [%s] %s\n' "$i" "$value"
		i=$((i + 1))
	done
}

tp_doctor_count_sh_files() {
	local dir="$1"
	local count=0
	local file

	if [ ! -d "$dir" ]; then
		printf '0'
		return
	fi

	for file in "$dir"/*.sh; do
		[ -f "$file" ] || continue
		count=$((count + 1))
	done

	printf '%s' "$count"
}

tp_doctor_command_path() {
	command -v "$1" 2>/dev/null || true
}

tp_doctor_git_version() {
	if [ -d "${TMUX_POWERLINE_DIR_HOME}/.git" ] && command -v git >/dev/null 2>&1; then
		git -C "$TMUX_POWERLINE_DIR_HOME" describe --tags --always --dirty 2>/dev/null || true
	fi
}

tp_doctor_active_theme_file() {
	if [ -n "$TMUX_POWERLINE_DIR_USER_THEMES" ] && [ -f "${TMUX_POWERLINE_DIR_USER_THEMES}/${TMUX_POWERLINE_THEME}.sh" ]; then
		printf '%s' "${TMUX_POWERLINE_DIR_USER_THEMES}/${TMUX_POWERLINE_THEME}.sh"
	else
		printf '%s' "${TMUX_POWERLINE_DIR_THEMES}/${TMUX_POWERLINE_THEME}.sh"
	fi
}

tp_doctor_active_theme_origin() {
	if [ -n "$TMUX_POWERLINE_DIR_USER_THEMES" ] && [ -f "${TMUX_POWERLINE_DIR_USER_THEMES}/${TMUX_POWERLINE_THEME}.sh" ]; then
		printf '%s' 'user theme override'
	else
		printf '%s' 'bundled theme'
	fi
}

tp_doctor_tmux_server_reachable() {
	command -v tmux >/dev/null 2>&1 || return 1
	tmux list-sessions >/dev/null 2>&1
}

tp_doctor_tmux_option() {
	local option="$1"
	local value

	value=$(tmux show-option -gqv "$option" 2>/dev/null)
	tp_doctor_print_value "$option" "$value"
}

tp_doctor_extract_powerline_path() {
	local value="$1"

	printf '%s\n' "$value" | sed -n 's|.*#(\(.*\/powerline\.sh\) [^)]*).*|\1|p' | head -n 1
}

tp_doctor_resolve_path() {
	local target="$1"
	local dir
	local link

	[ -n "$target" ] || return

	if [ ! -e "$target" ] && [ ! -L "$target" ]; then
		printf '%s' "$target"
		return
	fi

	case "$target" in
		/*) ;;
		*) target="$(pwd)/$target" ;;
	esac

	while [ -L "$target" ]; do
		dir="$(cd "$(dirname "$target")" && pwd -P)" || break
		link=$(readlink "$target") || break

		case "$link" in
			/*) target="$link" ;;
			*) target="${dir}/${link}" ;;
		esac
	done

	dir="$(cd "$(dirname "$target")" && pwd -P)" || {
		printf '%s' "$target"
		return
	}

	printf '%s/%s' "$dir" "$(basename "$target")"
}

tmux_powerline_version=$(tp_doctor_git_version)
tmux_path=$(tp_doctor_command_path tmux)
bash_path=$(tp_doctor_command_path bash)
git_path=$(tp_doctor_command_path git)
theme_file=$(tp_doctor_active_theme_file)
bundled_segments_count=$(tp_doctor_count_sh_files "$TMUX_POWERLINE_DIR_SEGMENTS")
bundled_themes_count=$(tp_doctor_count_sh_files "$TMUX_POWERLINE_DIR_THEMES")
user_segments_count=$(tp_doctor_count_sh_files "$TMUX_POWERLINE_DIR_USER_SEGMENTS")
user_themes_count=$(tp_doctor_count_sh_files "$TMUX_POWERLINE_DIR_USER_THEMES")
inside_tmux="no"
tmux_server_reachable="no"
tmux_wired="unknown"
live_powerline_path=""
live_powerline_path_resolved=""
doctor_powerline_path_resolved=$(tp_doctor_resolve_path "${TMUX_POWERLINE_DIR_HOME}/powerline.sh")

if [ -n "$TMUX" ]; then
	inside_tmux="yes"
fi

if [ -z "$tmux_path" ]; then
	tp_doctor_add_warning 'tmux was not found in PATH.'
fi

if [ ! -f "$TMUX_POWERLINE_CONFIG_FILE" ]; then
	tp_doctor_add_warning "Config file not found at ${TMUX_POWERLINE_CONFIG_FILE}; tmux-powerline is using resolved defaults and theme values."
fi

if [ ! -f "$theme_file" ]; then
	tp_doctor_add_warning "Configured theme file is missing: ${theme_file}"
fi

if tp_doctor_tmux_server_reachable; then
	tmux_server_reachable="yes"
	status_left=$(tmux show-option -gqv status-left 2>/dev/null)
	status_right=$(tmux show-option -gqv status-right 2>/dev/null)
	live_powerline_path=$(tp_doctor_extract_powerline_path "$status_left")

	if [ -z "$live_powerline_path" ]; then
		live_powerline_path=$(tp_doctor_extract_powerline_path "$status_right")
	fi

	live_powerline_path_resolved=$(tp_doctor_resolve_path "$live_powerline_path")

	if printf '%s\n%s\n' "$status_left" "$status_right" | grep -F '/powerline.sh' >/dev/null 2>&1; then
		tmux_wired="yes"
	else
		tmux_wired="no"
		tp_doctor_add_warning 'tmux server is reachable, but status-left/right do not reference powerline.sh.'
	fi

	if [ -n "$live_powerline_path_resolved" ] && [ "$live_powerline_path_resolved" != "$doctor_powerline_path_resolved" ]; then
		tp_doctor_add_warning "tmux is currently executing ${live_powerline_path}, which differs from this checkout's ${TMUX_POWERLINE_DIR_HOME}/powerline.sh."
	fi
fi

tp_doctor_print_header

tp_doctor_print_section 'Summary'
tp_doctor_print_value 'tmux-powerline version' "${tmux_powerline_version:-unknown}"
tp_doctor_print_value 'tmux binary' "${tmux_path:-not found}"
tp_doctor_print_value 'tmux server reachable' "$tmux_server_reachable"
tp_doctor_print_value 'inside tmux' "$inside_tmux"
tp_doctor_print_value 'tmux-powerline wired' "$tmux_wired"
tp_doctor_print_value 'live powerline.sh path' "${live_powerline_path:-unknown}"
tp_doctor_print_value 'resolved powerline.sh path' "${live_powerline_path_resolved:-unknown}"
tp_doctor_print_value 'active theme origin' "$(tp_doctor_active_theme_origin)"

tp_doctor_print_section 'System'
tp_doctor_print_value 'uname' "$(uname -srm 2>/dev/null)"
tp_doctor_print_value 'hostname' "$(hostname 2>/dev/null)"
if tp_shell_is_macos && command -v sw_vers >/dev/null 2>&1; then
	tp_doctor_print_value 'macOS version' "$(sw_vers -productVersion 2>/dev/null)"
fi
tp_doctor_print_value 'bash' "${BASH_VERSION:-unknown}"
tp_doctor_print_value 'bash path' "${bash_path:-unknown}"
tp_doctor_print_value 'git path' "${git_path:-not found}"
tp_doctor_print_value 'shell platform' "$SHELL_PLATFORM"
tp_doctor_print_value 'TERM' "${TERM-}"
tp_doctor_print_value 'TMUX' "${TMUX-}"

if [ -n "$tmux_path" ]; then
	tp_doctor_print_value 'tmux version' "$(tmux -V 2>/dev/null)"
fi

tp_doctor_print_section 'Resolved paths'
tp_doctor_print_path_var 'TMUX_POWERLINE_DIR_HOME'
tp_doctor_print_path_var 'TMUX_POWERLINE_DIR_LIB'
tp_doctor_print_path_var 'TMUX_POWERLINE_DIR_SEGMENTS'
tp_doctor_print_path_var 'TMUX_POWERLINE_DIR_THEMES'
tp_doctor_print_path_var 'TMUX_POWERLINE_DIR_TEMPORARY'
tp_doctor_print_path_var 'TMUX_POWERLINE_CONFIG_DIR'
tp_doctor_print_path_var 'TMUX_POWERLINE_CONFIG_FILE'
tp_doctor_print_path_var 'TMUX_POWERLINE_CONFIG_FILE_DEFAULT'
tp_doctor_print_path_var 'TMUX_POWERLINE_DIR_USER_SEGMENTS'
tp_doctor_print_path_var 'TMUX_POWERLINE_DIR_USER_THEMES'
tp_doctor_print_value 'this powerline.sh path' "$doctor_powerline_path_resolved"
tp_doctor_print_value 'active theme file' "$theme_file"
tp_doctor_print_value 'bundled segments' "$bundled_segments_count"
tp_doctor_print_value 'bundled themes' "$bundled_themes_count"
tp_doctor_print_value 'user segments' "$user_segments_count"
tp_doctor_print_value 'user themes' "$user_themes_count"

tp_doctor_print_section 'Resolved tmux-powerline settings'
tp_doctor_print_var 'TMUX_POWERLINE_DEBUG_MODE_ENABLED'
tp_doctor_print_var 'TMUX_POWERLINE_ERROR_LOGS_ENABLED'
tp_doctor_print_var 'TMUX_POWERLINE_ERROR_LOGS_SCOPES'
tp_doctor_print_var 'TMUX_POWERLINE_PATCHED_FONT_IN_USE'
tp_doctor_print_var 'TMUX_POWERLINE_THEME'
tp_doctor_print_var 'TMUX_POWERLINE_STATUS_VISIBILITY'
tp_doctor_print_var 'TMUX_POWERLINE_WINDOW_STATUS_LINE'
tp_doctor_print_var 'TMUX_POWERLINE_STATUS_INTERVAL'
tp_doctor_print_var 'TMUX_POWERLINE_STATUS_JUSTIFICATION'
tp_doctor_print_var 'TMUX_POWERLINE_STATUS_LEFT_LENGTH'
tp_doctor_print_var 'TMUX_POWERLINE_STATUS_RIGHT_LENGTH'
tp_doctor_print_var 'TMUX_POWERLINE_WINDOW_STATUS_SEPARATOR'
tp_doctor_print_var 'TMUX_POWERLINE_STATUS_STYLE'
tp_doctor_print_var 'TMUX_POWERLINE_MUTE_LEFT_KEYBINDING'
tp_doctor_print_var 'TMUX_POWERLINE_MUTE_RIGHT_KEYBINDING'
tp_doctor_print_array 'TMUX_POWERLINE_LEFT_STATUS_SEGMENTS' "${TMUX_POWERLINE_LEFT_STATUS_SEGMENTS[@]}"
tp_doctor_print_array 'TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS' "${TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS[@]}"

tp_doctor_print_section 'Live tmux options'
if [ "$tmux_server_reachable" = "yes" ]; then
	tp_doctor_tmux_option 'status'
	tp_doctor_tmux_option 'status-interval'
	tp_doctor_tmux_option 'status-justify'
	tp_doctor_tmux_option 'status-style'
	tp_doctor_tmux_option 'message-style'
	tp_doctor_tmux_option 'status-left-length'
	tp_doctor_tmux_option 'status-right-length'
	tp_doctor_tmux_option 'status-left'
	tp_doctor_tmux_option 'status-right'
	tp_doctor_tmux_option 'window-status-format'
	tp_doctor_tmux_option 'window-status-current-format'
	tp_doctor_tmux_option 'window-status-separator'
	tp_doctor_tmux_option 'status-format[0]'
	tp_doctor_tmux_option 'status-format[1]'
else
	tp_doctor_print_value 'tmux server' 'not reachable; no live tmux options available'
fi

tp_doctor_print_section 'Warnings'
if [ -n "$TP_DOCTOR_WARNINGS" ]; then
	printf '%s\n' "$TP_DOCTOR_WARNINGS" | while IFS= read -r warning; do
		printf '  - %s\n' "$warning"
	done
else
	printf '  %s\n' 'None'
fi

exit 0
