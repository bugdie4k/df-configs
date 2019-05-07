#!/usr/bin/env bash

# This file is to be sourced

HISTCONTROL=ignoredups:erasedups
HISTTIMEFORMAT="%Y.%m.%d %H:%M:%S "

# INFINITE (!) history
HISTSIZE=-1
HISTFILESIZE=-1
HISTFILE=~/.bash_infinite_history

# append history rather than rewrite on exit
shopt -s histappend

# after each prompt append history to history file
# nice reason not to include history -c; history -r:
# https://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows#comment67052_48116
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

