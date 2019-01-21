#!/usr/bin/env bash

# This file is to be sourced

# No cd, just enter the path
shopt -s autocd

# Disable ^S and ^Q
stty -ixon

# dir with custom scripts
mkdir -p "$HOME/bin"
PATH="$PATH:$HOME/bin"

# History settings
HISTCONTROL=ignoredups:erasedups
HISTTIMEFORMAT="%Y.%m.%d %H:%M:%S "
# INFINITE (!) history
HISTSIZE=-1
HISTFILESIZE=-1
# append history rather than rewrite on exit
shopt -s histappend
# after each prompt append history to history file
# nice reason not to include history -c; history -r:
# https://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows#comment67052_48116
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

if [[ $(whoami) = 'df' ]]; then
  DF_THIS_MACHINE=home
  DF_CONFIGS=~/df-configs
  # DF_LOCAL_CONFIGS=$DF_CONFIGS/local
elif [[ $(whoami) = 'dfedorov' ]]; then
  DF_THIS_MACHINE=work
  DF_CONFIGS=~/configs
  DF_LOCAL_CONFIGS=~/sensitive-configs
fi
readonly DF_CONFIGS
readonly DF_LOCAL_CONFIGS
readonly DF_THIS_MACHINE

# source chunks
for bashrc_chunk  in $(/bin/ls -A ~/.bashrc.d/*.*.bashrc); do
  . "$bashrc_chunk"
done

if [[ ! -z $DF_LOCAL_CONFIGS ]]; then
  . $DF_LOCAL_CONFIGS/local.bashrc
fi
