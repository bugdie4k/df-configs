#!/usr/bin/env bash

# This file is to be sourced

# Disable ^S and ^Q
stty -ixon

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

# source chunks
for bashrc_chunk  in $(/bin/ls -A ~/.bashrc.d/*.*.bashrc); do
  . "$bashrc_chunk"
done

# source local configs
if [[ ! -z $DF_LOCAL_CONFIGS ]]; then
  . $DF_LOCAL_CONFIGS/local.bashrc
fi
