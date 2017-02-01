# Indicator of pressing TMUX prefix

prefix_mode_text="  TMUX PREFIX PRESSED  "
normal_mode_text="NORMAL MODE"
prefix_mode_fg="colour51"
normal_mode_fg="colour16"
prefix_mode_indicator_bg="colour68"

run_segment() {
        echo "#[bg=${prefix_mode_indicator_bg}]#{?client_prefix,#[fg=${prefix_mode_fg}]${prefix_mode_text},#[fg=${normal_mode_fg}]${normal_mode_text}}"
        return 0
}
