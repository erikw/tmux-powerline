# shellcheck shell=bash
TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE_DEFAULT=project
TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL_DEFAULT='󱇶 '
TMUX_POWERLINE_SEG_GOOGLE_CLOUD_ACCOUNT_PROJECT_SEPARATOR_DEFAULT='󰿟'

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Which Google Cloud properties to display. Can be {"account", "project", "account_project", "active_config_name"}.
# export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE_DEFAULT"
# The symbol for Google Cloud.
# export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL_DEFAULT"
# The separator to use between Google Cloud account and project. This environment variable is used only when
# TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE is set to 'account_project'.
# export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_ACCOUNT_PROJECT_SEPARATOR="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_ACCOUNT_PROJECT_SEPARATOR_DEFAULT"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings

	if ! type gcloud >/dev/null 2>&1; then
		echo 'gcloud CLI was not found'
		return 1
	fi

	local format_expr status_text
	case "$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE" in
		account|project|active_config_name)
			format_expr="value(config.$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE)";;
		account_project)
			format_expr="value[separator='$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_ACCOUNT_PROJECT_SEPARATOR'](config.account,config.project)";;
		*)
			echo 'TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE must be one of account, project, account_project or active_config_name'
			return 1;;
	esac
	status_text="$(gcloud info --format="$format_expr")"
	[ -n "$status_text" ] && echo "${TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL}${status_text}"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE" ]; then
		export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_DISPLAY_MODE_DEFAULT"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_SYMBOL_DEFAULT"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_ACCOUNT_PROJECT_SEPARATOR" ]; then
		export TMUX_POWERLINE_SEG_GOOGLE_CLOUD_ACCOUNT_PROJECT_SEPARATOR="$TMUX_POWERLINE_SEG_GOOGLE_CLOUD_ACCOUNT_PROJECT_SEPARATOR_DEFAULT"
	fi
}
