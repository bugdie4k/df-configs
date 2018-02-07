# -*- mode: shell-script -*-

# This file is to be sourced

###### source scm stuff

source ${CONFIGS}/bash/prompt.scm_info.bash

###### colors

export PROMPT_BRACKET_COLOR=93
export PROMPT_PREV_RETURN_COLOR=129
export PROMPT_USER_COLOR=171
export PROMPT_TIME_DATE_COLOR=177
export PROMPT_SCM_COLOR=183
export PROMPT_PATH_COLOR=189

###### make prompt function

function prompt-set-ps1 () {
    : "echoes string that should be put to PS1 var to make up a prompt"

    ## components

    local bracket_left="$(tput setaf ${PROMPT_BRACKET_COLOR})["
    local bracket_right="$(tput setaf ${PROMPT_BRACKET_COLOR})]"
    local line1_start="$(tput setaf ${PROMPT_BRACKET_COLOR})┌─"
    local line2_start="$(tput setaf ${PROMPT_BRACKET_COLOR})└─"
    local prev_return="$(tput setaf ${PROMPT_PREV_RETURN_COLOR})\$?"
    local user="$(tput setaf ${PROMPT_USER_COLOR})\u";
    local path="$(tput setaf ${PROMPT_PATH_COLOR})\w";
    local time_date="$(tput setaf ${PROMPT_TIME_DATE_COLOR})\D{%a %d/%m/%y %T}";
    local normal="\[\e[0m\]"

    ## components to blocks

    # surrounds argument with square brackets
    make-block () { echo "${bracket_left}${@}${bracket_right}" ; }

    local prev_return_code_block=$(make-block $prev_return)
    local user_block=$(make-block $user)
    local path_block=$(make-block $path)
    local time_date_block=$(make-block $time_date)

    ## nested shell indicator
    # if i am in the nested shell, echoes a dot. useful to see quickly if mc is running
    # it can be called just one time when session starts, so there is no backslash in front of this func in PS1
    nested-shell-indicator () { if [ $SHLVL -gt 1 ] ; then for ((i=1; i<$SHLVL; i++ )) ; do echo -n "." ; done ; fi ; }

    ## scm things
    SCM_THEME_PROMPT_PREFIX="${bracket_left}$(tput setaf ${PROMPT_SCM_COLOR})"
    SCM_THEME_PROMPT_SUFFIX="${bracket_right}"
    SCM_THEME_PROMPT_DIRTY=" $(tput setaf 131)x" #✗
    SCM_THEME_PROMPT_CLEAN=" $(tput setaf 156)v" # ✓

    SCM_GIT_SHOW_DETAILS=true
    SCM_GIT_IGNORE_UNTRACKED=false
    SCM_GIT_SHOW_MINIMAL_INFO=false

    ## resulting PS1
    if [[ ! -z $1 ]] && [[ $1 = 'min' ]]; then
        SCM_GIT_SHOW_DETAILS=false
        SCM_GIT_IGNORE_UNTRACKED=true
        SCM_GIT_SHOW_MINIMAL_INFO=true
        SCM_THEME_PROMPT_DIRTY=''
        SCM_THEME_PROMPT_CLEAN=''
    fi
    PS1="${line1_start}${prev_return_code_block}${user_block}${time_date_block}\$(scm_prompt_info)${path_block}$(nested-shell-indicator)
└─ \$ ${normal}"
    #^ don't know why but making second line start with $line2_start messed my prompt somehow
}

###### experiment with colors, use function 'colors' to list all colors

function prompt-set-bracket-color () { PROMPT_BRACKET_COLOR=$1 ; prompt-set-ps1 ; }
function prompt-set-prev-return-color () { PROMPT_PREV_RETURN_COLOR=$1 ; prompt-set-ps1 ; }
function prompt-set-user-color () { PROMPT_USER_COLOR=$1 ; prompt-set-ps1 ; }
function prompt-set-time-date-color() { PROMPT_TIME_DATE_COLOR=$1 ; prompt-set-ps1 ; }
function prompt-set-scm-color () { PROMPT_SCM_COLOR=$1 ; prompt-set-ps1 ; }
function prompt-set-path-color () { PROMPT_PATH_COLOR=$1 ; prompt-set-ps1 ; }
function prompt-show-colors () {
    echo "BRACKET"
    color-info $PROMPT_BRACKET_COLOR
    echo "PREV RETURN"
    color-info $PROMPT_PREV_RETURN_COLOR
    echo "USER"
    color-info $PROMPT_USER_COLOR
    echo "TIME-DATE"
    color-info $PROMPT_TIME_DATE_COLOR
    echo "SCM"
    color-info $PROMPT_SCM_COLOR
    echo "PATH"
    color-info $PROMPT_PATH_COLOR
}
function prompt-set-colors () {
    prompt-set-bracket-color $1
    prompt-set-prev-return-color $2
    prompt-set-user-color $3
    prompt-set-time-date-color $4
    prompt-set-scm-color $5
    prompt-set-path-color $6
}

if [ $MACHINE = "work" ] ; then
    prompt-set-ps1 min
else
    prompt-set-ps1
fi

####### old one

# PS1='\[\033[38;5;234m\]{$?} \[\033[00;33m\]\w\n${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\u \[\033[00;36m\][\d \t]\[\033[00;00m\]\[\033[00;33m\] \$ \[\033[00;00m\]'
