# -*- mode: shell-script -*-

export SHELL=/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/root/.local/bin:/root/bin

###### determine my location and some dependent variables ######################

if [[ $(whoami) = "dfedorov" ]]; then
    MACHINE="work"
    CONFIGS=~/configs
    LOCAL_CONFIGS=~/sensitive-configs
elif [[ $(whoami) = "bugdie4k" ]]; then
    MACHINE="home"
    CONFIGS=~/projects/configs
    LOCAL_CONFIGS=$CONFIGS/bash
elif [[ $(whoami) = "kate" ]]; then
    MACHINE="kate"
    CONFIGS=~/configs
    LOCAL_CONFIGS=$CONFIGS/bash
elif [[ $(whoami) = "bugdie4k2" ]]; then
    MACHINE="home2"
    CONFIGS=~/configs
    LOCAL_CONFIGS=$CONFIGS/bash
elif [[ $(whoami) = "bugdie4kdndz" ]]; then
    MACHINE="dndz"
    CONFIGS=~/configs
    LOCAL_CONFIGS=$CONFIGS/bash
fi

export MACHINE
export CONFIGS_REPO
export CONFIGS
export LOCAL_CONFIGS

###### PATHs ###################################################################

# dir with custom scripts
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"

###### if running bash source bashrc ###########################################

if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -e "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi
