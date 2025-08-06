# shellcheck shell=bash
# Shell Configuration
# vi: sw=8 ts=8 noet

tp_ostype() { echo "$OSTYPE" | tr '[:upper:]' '[:lower:]'; }

export SHELL_PLATFORM='unknown'

case "$(tp_ostype)" in
*'linux'*) SHELL_PLATFORM='linux' ;;
*'darwin'*) SHELL_PLATFORM='macos' ;;
*'bsd'*) SHELL_PLATFORM='bsd' ;;
esac

tp_shell_is_linux() { [[ $SHELL_PLATFORM == 'linux' || $SHELL_PLATFORM == 'bsd' ]]; }
tp_shell_is_macos() { [[ $SHELL_PLATFORM == 'macos' ]]; }
tp_shell_is_bsd() { [[ $SHELL_PLATFORM == 'bsd' || $SHELL_PLATFORM == 'macos' ]]; }

export -f tp_shell_is_linux
export -f tp_shell_is_macos
export -f tp_shell_is_bsd
