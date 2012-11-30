#!/bin/sh

debug_mode_enabled  () {
  [ -n "$TMUX_POWERLINE_DEBUG_MODE_ENABLED" -a "$TMUX_POWERLINE_DEBUG_MODE_ENABLED" != "false" ];
}

patched_font_in_use () {
  [ -z "$TMUX_POWERLINE_PATCHED_FONT_IN_USE" -o "$TMUX_POWERLINE_PATCHED_FONT_IN_USE" != "false" ];
}

export SHELL_PLATFORM='OTHER'

case "$OSTYPE" in
  *'linux'*   ) SHELL_PLATFORM='LINUX' ;;
  *'darwin'*  ) SHELL_PLATFORM='OSX' ;;
  *'freebsd'* ) SHELL_PLATFORM='BSD' ;;
esac
