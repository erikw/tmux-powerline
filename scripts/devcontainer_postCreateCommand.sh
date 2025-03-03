#!/usr/bin/env bash
# Devcontainer postCreateCommand.
# Install dependencies for running this project in GitHub Codespaces.

set -eux

# Defensive sysop: in case user's dotfiles installed tmux configs already.
## Tmux
rm -rf ${XDG_CONFIG_HOME:-$HOME/.config}/tmux
rm -rf $HOME/.tmux

## tmux-powerline
rm -rf ${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline
rm -rf $HOME/.tmux-powerline
rm -f $HOME/.tmuxpowerlinerc


# Set up TPM. Ref: https://github.com/tmux-plugins/tpm?#installation
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

cat << TMUXCONF > $HOME/.tmux.conf
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
# Install tmux-powerline as a "local plugin". Ref: https://github.com/tmux-plugins/tpm/issues/220#issuecomment-1082686994
run '/workspaces/tmux-powerline/main.tmux'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
TMUXCONF

# Install TPM plugins
$HOME/.tmux/plugins/tpm/bin/install_plugins