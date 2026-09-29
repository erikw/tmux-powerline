# shellcheck shell=bash

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"
# shellcheck source=lib/ini_helper.sh
source "${TMUX_POWERLINE_DIR_LIB}/ini_helper.sh"

TMUX_POWERLINE_SEG_GOOGLE_CLOUD_PROPERTIES_TO_DISPLAY_DEFAULT=account,project
TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL_DEFAULT='󱇶'
TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SEPARATOR_DEFAULT='󰿟'

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Comma-separated list of Google Cloud properties to display. Available values: "account", "project", "active_config_name".
# export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_PROPERTIES_TO_DISPLAY="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_PROPERTIES_TO_DISPLAY_DEFAULT"
# The symbol for Google Cloud.
# export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL_DEFAULT"
# The separator to use between properties.
# export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SEPARATOR="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SEPARATOR_DEFAULT"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings

	local config_dir="${CLOUDSDK_CONFIG:-$HOME/.config/gcloud}"
	local active_config_name="$CLOUDSDK_ACTIVE_CONFIG_NAME"
	# Leave the name empty if there is no configuration directory, so that nothing
	# is displayed on a machine where Google Cloud CLI has never been set up.
	if [ -z "$active_config_name" ] && [ -d "$config_dir" ]; then
		if [ -r "$config_dir/active_config" ]; then
			active_config_name="$(<"$config_dir/active_config")"
		fi
		active_config_name="${active_config_name:-default}"
	fi
	local active_config_file="$config_dir/configurations/config_$active_config_name"

	local props prop prop_value status_text
	IFS=', ' read -ra props <<<"$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_PROPERTIES_TO_DISPLAY"
	for prop in "${props[@]}"; do
		[ -n "$prop" ] || continue
		case "$prop" in
			account)
				prop_value="${CLOUDSDK_CORE_ACCOUNT:-$(tp_get_ini_value "$active_config_file" core account)}";;
			project)
				prop_value="${CLOUDSDK_CORE_PROJECT:-$(tp_get_ini_value "$active_config_file" core project)}";;
			active_config_name)
				prop_value="$active_config_name";;
			*)
				tp_err_seg "Err: Invalid property '$prop' in TMUX_POWERLINE_SEG_GOOGLE_CLOUD_PROPERTIES_TO_DISPLAY"
				return 1
				;;
		esac
		if [ -z "$status_text" ]; then
			status_text="$prop_value"
		elif [ -n "$prop_value" ]; then
			status_text="${status_text}${TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SEPARATOR}${prop_value}"
		fi
	done
	[ -n "$status_text" ] && echo "${TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL} ${status_text}"
	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_PROPERTIES_TO_DISPLAY" ]; then
		export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_PROPERTIES_TO_DISPLAY="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_PROPERTIES_TO_DISPLAY_DEFAULT"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL_DEFAULT"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SEPARATOR" ]; then
		export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SEPARATOR="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SEPARATOR_DEFAULT"
	fi
}
