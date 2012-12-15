#!/usr/bin/env bash
# Generate default rc file.

cwd="$(dirname $0)"
source "${cwd}/config/paths.sh"
source "${cwd}/lib/rcfile.sh"

generate_default_rc

exit 0
