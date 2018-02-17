# -*- mode: shell-script -*-

# This file is to be sourced

export GREP_COLOR='1;33'

# This is what i did:
# "To turn off bash completion when running from emacs but keep it on for processes started by bash-completion.el, add this to your .bashrc:"
if [[ ( -z "$INSIDE_EMACS" || "$EMACS_BASH_COMPLETE" = "t" ) &&\
     -f /etc/bash_completion ]]; then
  . /etc/bash_completion
fi
export IBUS_ENABLE_SYNC_MODE=1

# colorful terminal
export TERM=xterm-256color

# golang
export GOPATH=~/projects/goworkspace
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOPATH/bin

# figlet fonts place
export FIGLET_FONTDIR=~/.local/share/figlet

# lein
export LEIN_JAR=~/.lein/self-installs/leiningen-2.8.1-standalone.jar

# path to jdk 9.0.4
# export PATH=$PATH:~/sources/jdk-9.0.4/bin
# export JAVA_CMD=~/sources/jdk-9.0.4/bin/java

# ----------- fzf theme -----------

# Base16 Rebecca4k (bugdie4k's spin on Base16 Rebecca)
# Author: Victor Borja (http://github.com/vic) based on Rebecca Theme (http://github.com/vic/rebecca-theme)

_gen_fzf_default_opts() {

    local color00='#050507'
    local color01='#663399'
    local color02='#383a62'
    local color03='#666699'
    local color04='#a0a0c5'
    local color05='#f1eff8'
    local color06='#ccccff'
    local color07='#53495d'
    local color08='#a0a0c5'
    local color09='#efe4a1'
    local color0A='#ae81ff'
    local color0B='#6dfedf'
    local color0C='#8eaee0'
    local color0D='#2de0a7'
    local color0E='#7aa5ff'
    local color0F='#ff79c6'

    export FZF_DEFAULT_OPTS="
  --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D
  --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
  --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D
"

}

_gen_fzf_default_opts
