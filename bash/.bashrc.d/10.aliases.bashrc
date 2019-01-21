#!/usr/bin/env bash

# This file is to be sourced

# ls
if type exa-linux-x86_64 >/dev/null 2>&1; then
  alias ls=exa-linux-x86_64
  alias l='ls -aFh'
else
  alias ls='ls --color=auto'
  alias l='ls -aFhC'
fi
alias ll='ls -aFhl'

# sudo
alias _="sudo"

# up to 10
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'
alias ..........='cd ../../../../../../../../..'

# directory
alias md='mkdir -p'
alias rd='rmdir'

# kdiff3
alias kd3="kdiff3"

# git
alias g='git'
alias gk='gitk'
alias gka='gitk --all'

# copy/paste
# $ echo "hello" | pbcopy
# $ pbpaste
# hello
alias pbcopy='xclip -selection clipboard'
alias pbpaste="xclip -selection clipboard -o"
pbcopyn(){ echo -n "$1" | pbcopy; } # copy name

# change layout
alias layua='setxkbmap -layout "us,ua"'
alias layru='setxkbmap -layout "us,ru"'

# gvim
alias vi=gvim-client-or-server

# visual studio code
alias vc=code

# emacs
alias e=emacs-client-or-daemon

# ranger
alias ra='. ranger'

# timewarrior
alias tw=timew

# taskwarrior
alias t=task

# make executable
alias mkexec='chmod u+x'

# ripgrep, silversearcher
alias rg='rg --hidden'
alias ag='ag --hidden'

