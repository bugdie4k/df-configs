# -*- mode: shell-script -*-

# This file is to be sourced

##### Variables exported here are going into the global environment ###########

export SHELL=/bin/bash

##### Determine my location and some dependent variables ######################

export DF_THIS_MACHINE=''
export DF_CONFIGS=''
export DF_LOCAL_CONFIGS=''

if [ "$(whoami)" = 'dfedorov' ]; then
    DF_THIS_MACHINE='work'
    DF_CONFIGS=~/configs
    DF_LOCAL_CONFIGS=~/sensitive-configs
elif [ "$(whoami)" = 'bugdie4k' ]; then
    DF_THIS_MACHINE='home'
    DF_CONFIGS=~/configs
    DF_LOCAL_CONFIGS=$DF_CONFIGS/bash
elif [ "$(whoami)" = 'kate' ]; then
    DF_THIS_MACHINE='kate'
    DF_CONFIGS=~/configs
    DF_LOCAL_CONFIGS=$DF_CONFIGS/bash
elif [ $(whoami) = 'bugdie4k2' ]; then
    DF_THIS_MACHINE='home2';
    DF_CONFIGS=~/configs
    DF_LOCAL_CONFIGS=$DF_CONFIGS/bash
elif [ $(whoami) = 'bugdie4kdndz' ]; then
    DF_THIS_MACHINE='dndz'
    DF_CONFIGS=~/configs
    DF_LOCAL_CONFIGS=$DF_CONFIGS/bash
fi

###### PATHs ##################################################################

# dir with custom scripts
PATH="$PATH:$HOME/bin"
# another location for per user executables
PATH="$PATH:$HOME/.local/bin"

###### If running bash source bashrc ##########################################

if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -e "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi
