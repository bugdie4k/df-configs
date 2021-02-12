#!/usr/bin/env bash

# This file is to be sourced

if [[ "$TERM" != "" ]]; then
  # Disable ^S and ^Q
  stty -ixon
fi

df__ini_tput() {
  if [[ "$TERM" != "" ]]; then
    tput "$@"
  fi
}
export -f df__ini_tput

# source chunks
for bashrc_chunk  in $(/bin/ls -A ~/.bashrc.d/*.*.bashrc); do
  . "$bashrc_chunk"
done

# source local configs
if [[ ! -z $DF_LOCAL_CONFIGS ]]; then
  . $DF_LOCAL_CONFIGS/local.bashrc
fi

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/__tabtab.bash ] && . ~/.config/tabtab/__tabtab.bash || true

# Added by serverless binary installer
export PATH="$HOME/.serverless/bin:$PATH"

complete -C '/usr/local/bin/aws_completer' aws

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source "$HOME/.cargo/env"
