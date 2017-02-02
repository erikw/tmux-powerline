# Indicator of pressing TMUX prefix, copy and insert modes.

prefix_pressed_text="PREFIX PRESSED"
insert_mode_text="INSERT"
copy_mode_text="COPY"
normal_mode_text="NORMAL"
separator="✤"

prefix_mode_fg="colour226"
normal_mode_fg="colour16"
copy_mode_fg="colour82"
bg="colour33"

run_segment() {
        prefix_indicator="#[bg=${bg}]#{?client_prefix,#[fg=${prefix_mode_fg}]${prefix_pressed_text},#[fg=${normal_mode_fg}]${normal_mode_text}}"
        normal_or_copy_indicator="#[bg=${bg}]#{?pane_in_mode,#[fg=${copy_mode_fg}]${copy_mode_text},#[fg=${normal_mode_fg}]${insert_mode_text}}";
        echo $prefix_indicator "#[fg=${normal_mode_fg}]${separator}" $normal_or_copy_indicator
        return 0
}
