###
# Shell Configuration
#
export SHELL_PLATFORM='OTHER'

case "$OSTYPE" in
  *'linux'*   ) SHELL_PLATFORM='LINUX' ;;
  *'darwin'*  ) SHELL_PLATFORM='OSX' ;;
  *'freebsd'* ) SHELL_PLATFORM='BSD' ;;
esac

shell_is_linux () { [[ $SHELL_PLATFORM == 'BSD' || $SHELL_PLATFORM == 'LINUX' ]]; }
shell_is_osx   () { [[ $SHELL_PLATFORM == 'OSX' ]]; }

export -f shell_is_linux
export -f shell_is_osx
