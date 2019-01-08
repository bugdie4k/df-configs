# -*- mode: shell-script -*-
# vi:syntax=sh

# This file is to be sourced

export DF_CONFIGS
export DF_LOCAL_CONFIGS
export DF_THIS_MACHINE
if [[ $(whoami) = 'df' ]]; then
  DF_THIS_MACHINE=home
  DF_CONFIGS=~/df-configs
  DF_LOCAL_CONFIGS=$DF_CONFIGS/local
elif [[ $(whoami) = 'dfedorov' ]]; then
  DF_THIS_MACHINE=work
  DF_CONFIGS=~/configs
  DF_LOCAL_CONFIGS=~/sensitive-configs
fi
readonly DF_CONFIGS
readonly DF_LOCAL_CONFIGS
readonly DF_THIS_MACHINE

setxkbmap -layout us -option 'ctrl:swapcaps'
setxkbmap -layout 'us,ru'
setxkbmap -option 'grp:win_space_toggle'

# dir with custom scripts
mkdir -p "$HOME/bin"
PATH="$PATH:$HOME/bin"

for part in $(/bin/ls -A $DF_CONFIGS/bash/.bashrc.d/*.*.bashrc); do
  . "$part"
done
