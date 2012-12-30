# Shell Configuration
# vi: sw=8 ts=8 noet

export SHELL_PLATFORM='unknown'

case "$OSTYPE" in
	*'linux'*	) SHELL_PLATFORM='linux'	;;
	*'darwin'*	) SHELL_PLATFORM='osx'		;;
	*'bsd'*		) SHELL_PLATFORM='bsd'		;;
esac

shell_is_linux() { [[ $SHELL_PLATFORM == 'bsd' || $SHELL_PLATFORM == 'linux' ]]; }
shell_is_osx() { [[ $SHELL_PLATFORM == 'osx' ]]; }
shell_is_bsd() { [[ $SHELL_PLATFORM == 'bsd' || $SHELL_PLATFORM == 'osx' ]]; }

export -f shell_is_linux
export -f shell_is_osx
export -f shell_is_bsd
