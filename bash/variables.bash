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
