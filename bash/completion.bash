# -*- mode: shell-script -*-

# This file is to be sourced

###### bash completion #########################################################

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

###### git completion ##########################################################

if [ -f ~/.git-completion.bash ]; then
    source ~/.git-completion.bash
    # Add git completion to aliases
    __git_complete g __git_main # now completion works with 'g' instead of 'git'
else
    echo "DIDN'T FIND ~/.git-completion.bash"
fi

###### completion functions ####################################################

__wd_completion() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    opts="--help --verbose --version"
    warp_points=$(_wd -l 2>&1 | tail -n +2 | awk -F '->' '{print $1}')

    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    else
        COMPREPLY=( $(compgen -W "${warp_points}" -- ${cur}) )
        return 0
    fi
}

complete -F __wd_completion wd
