#!/bin/sh

# This file is to be sourced (by ~/.xinitrc or ~/.xsession)

# dir with custom scripts
mkdir -p "$HOME/bin"
PATH="$PATH:$HOME/bin"
PATH="$PATH:$HOME/.local/bin"

# style for highlight command
export DF_HIGHLIGHT_STYLE=denim

# determine this machine
export DF_THIS_MACHINE
export DF_CONFIGS
export DF_LOCAL_CONFIGS
if [ "$(whoami)" = 'df' ]; then
  DF_THIS_MACHINE=home2
  DF_CONFIGS=~/df-configs
  # DF_LOCAL_CONFIGS=$DF_CONFIGS/local
elif [ "$(whoami)" = 'dfedorov' ]; then
  DF_THIS_MACHINE=work2
  DF_CONFIGS=~/df-configs
  DF_LOCAL_CONFIGS=~/sensitive-configs
# elif [ "$(whoami)" = 'ubuntu' ]; then
#   DF_THIS_MACHINE=work2
#   DF_CONFIGS=~/df-configs
#   DF_LOCAL_CONFIGS=~/sensitive-configs
fi
readonly DF_CONFIGS
readonly DF_LOCAL_CONFIGS
readonly DF_THIS_MACHINE

export SUDO_EDITOR=gvim
export EDITOR=gvim
export BROWSER=vivaldi-stable
export TERMINAL=gnome-terminal
SHELL="$(command -v bash)"
export SHELL

# if [ $DF_THIS_MACHINE = 'work' ]; then
#   xrandr --output HDMI1 --auto --output VGA1 --auto --left-of HDMI1
# fi

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

export PATH="$HOME/.serverless/bin:$PATH"
