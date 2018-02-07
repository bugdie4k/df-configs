# -*- mode: shell-script -*-

# This file is to be sourced

###### HELLO WORLD #############################################################

echo "MACHINE: $MACHINE"

###### local settings ##########################################################

case $MACHINE in
    home|home2|kate) . ${LOCAL_CONFIGS}/local.home.bash ;;
    work) . ${LOCAL_CONFIGS}/bash.local.work ;;
    *) echo ".bashrc: Don't know where to find locals for this machine."
esac

###### my stuff ################################################################

. ${CONFIGS}/bash/default-stuff.bash
. ${CONFIGS}/bash/variables.bash
. ${CONFIGS}/bash/coloring.bash
. ${CONFIGS}/bash/functions.bash
. ${CONFIGS}/bash/aliases.bash
. ${CONFIGS}/bash/completion.bash
. ${CONFIGS}/bash/logprint.bash
. ${CONFIGS}/bash/prompt.bash

###### also source #############################################################

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
