# Shell Configuration

export SHELL_PLATFORM='unknown'

case "$OSTYPE" in
  *'linux'*   ) SHELL_PLATFORM='linux' ;;
  *'darwin'*  ) SHELL_PLATFORM='osx' ;;
  *'freebsd'* ) SHELL_PLATFORM='bsd' ;;
esac

shell_is_linux () { [[ $SHELL_PLATFORM == 'bsd' || $SHELL_PLATFORM == 'linux' ]]; }
shell_is_osx   () { [[ $SHELL_PLATFORM == 'osx' ]]; }

export -f shell_is_linux
export -f shell_is_osx
