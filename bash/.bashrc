# -*- mode: shell-script -*-

# This file is to be sourced

###### Source configs #########################################################

. ${DF_CONFIGS}/bash/.bashrc.default-stuff
. ${DF_CONFIGS}/bash/.bashrc.variables
. ${DF_CONFIGS}/bash/.bashrc.misc
. ${DF_CONFIGS}/bash/.bashrc.functions
. ${DF_CONFIGS}/bash/.bashrc.aliases
. ${DF_CONFIGS}/bash/.bashrc.completion
. ${DF_CONFIGS}/bash/.bashrc.prompt

###### Source local configs ###################################################

case $DF_THIS_MACHINE in
    home|home2|kate) . ${DF_LOCAL_CONFIGS}/.bashrc.local.home ;;
    work) . ${DF_LOCAL_CONFIGS}/bash.local.work ;;
    *) echo ".bashrc: Don't know where to find local configs for this machine." ;;
esac

###### Also source ############################################################

also_source() {
    if [ -f $1 ]; then
        . $1
    else
        echo ".bashrc: Wanted to source $1 but didn't find one."
    fi
}

also_source /etc/profile.d/vte-2.91.sh
also_source ~/.fzf.bash

unset -f also_source
