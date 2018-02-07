# -*- mode: shell-script -*-

# This file is to be sourced

# TODO: make a separate script

_SE_CUR_NAME_FILE_PREFIX=~/.switch-emacs.current-emacs
_SE_SUFFIX=se

_SE_MAGENTA=201
_SE_YELLOW=3
_SE_RED=1

__switch-emacs_help(){
    echo 'USAGE:'
    echo '  switch-emacs [--list|-l] [--new|-n NEWNAME] [--help|-h] [NAME]'
    echo
    echo '  [--list|-l]'
    echo '      Prints all available dotemacses.'
    echo '      Without args prints name of current emacs.'
    echo '      NAME is a name of emacs to switch to.'
    echo '  [--new|-n NEWNAME]'
    echo '      Creates new dir for new config.'
    echo '      NEWNAME is LNAME+SNAME or LNAME SNAME (with space) or LNAME'
}

__switch-emacs_list(){
    local lname sname # long and short

    sname=$2
    lname=$1

    [ "$lname" == "$sname" ] && sname=""

    tput setaf $_SE_MAGENTA
    printf "*  %-3s %s\n" "$sname" "$lname"
    tput sgr0

    for full_name in ~/.emacs.d.$_SE_SUFFIX.*; do
        full_name=${full_name##*.}
        lname=${full_name%%+*}
        sname=${full_name##*+}

        [ "$lname" == "$sname" ] && sname=""

        tput setaf $_SE_YELLOW
        printf "   %-3s %s\n" "$sname" "$lname"
        tput sgr0
    done
}

__switch-emacs_validate_name(){
    [ "$2" = "$1" ] || [ "$3" = "$1" ] && echo -n "$2+$3" && return 0
    local lname sname # long and short
    for full_name in ~/.emacs.d.$_SE_SUFFIX.*; do
        full_name=${full_name##*.}
        lname=${full_name%%+*}
        sname=${full_name##*+}
        [ "$lname" = "$1" ] || [ "$sname" = "$1" ] && echo -n "$lname+$sname" && return 0
    done
    echo -n ""
}

__switch-emacs_new(){
    local lname sname
    if [ "$1" == "" ] && [ "$2" == "" ]; then
        read -p "long name: " lname
        read -p "short name: " sname
    elif [ "$1" != "" ] && [ "$2" == "" ]; then
        lname=${1%%+*}
        sname=${1##*+}
    elif [ "$1" != "" ] && [ "$2" != "" ]; then
        lname=$1
        sname=$2
    fi

    if [ "$lname" == "$sname" ]; then
        mkdir ~/.emacs.d.$_SE_SUFFIX.$lname
    else
        mkdir ~/.emacs.d.$_SE_SUFFIX.$lname+$sname
    fi
}

switch-emacs(){
    # figure out current emacs
    local full_curr scurr lcurr
    full_curr=$(ls $_SE_CUR_NAME_FILE_PREFIX.*)
    full_curr=${full_curr##*.}
    scurr=${full_curr##*+} # s for short
    [ "$scurr" == "$lcurr" ] && scurr=""
    lcurr=${full_curr%%+*} # l for long

    # deal with args
    if [ $# -eq 0 ]; then
        tput setaf $_SE_MAGENTA
        echo "CURRENT: ${lcurr^^} ($scurr)" # ^^ for upcase
        figlet -f kban -w 160 ${lcurr^^}
        tput sgr0

        return 0
    fi

    case "$1" in
        -l|--list) __switch-emacs_list $lcurr $scurr; return $? ;;
        -n|--new) __switch-emacs_new $2 $3; return $? ;;
        -h|--help|help) __switch-emacs_help; return $? ;;
        *) local new="$1" ;;
    esac

    # make new take a long form
    new=$(__switch-emacs_validate_name $new $lcurr $scurr)
    if [ -z "$new" ]; then
        tput setaf $_SE_RED
        echo "switch-emacs: WRONG EMACS NAME, USE ONE OF THESE:"
        tput sgr0

        __switch-emacs_list $lcurr $scurr
        return 1
    fi

    local snew lnew
    snew=${new##*+}
    lnew=${new%%+*}

    # tell about previous emacs
    tput setaf $_SE_YELLOW
    echo "PREVIOUS: ${lcurr^^} ($scurr)"
    figlet -f kban -w 160 ${lcurr^^}
    tput sgr0

    # report if they are the same
    if [ "$lnew" = "$lcurr" ]; then
        tput setaf $_SE_RED
        echo "${lnew^^} IS CURRENT ALREADY";
        tput sgr0

        return
    fi

    # rename file to new name
    mv $_SE_CUR_NAME_FILE_PREFIX.$full_curr $_SE_CUR_NAME_FILE_PREFIX.$new
    [ $? -eq 0 ] && echo -n '.' || echo -n 'x'

    # rename emacs dir
    mv  ~/.emacs.d ~/.emacs.d.$_SE_SUFFIX.$full_curr
    [ $? -eq 0 ]  && echo -n '.' || echo -n 'x'
    mv ~/.emacs.d.$_SE_SUFFIX.$new ~/.emacs.d
    [ $? -eq 0 ]  && echo '.' || echo 'x'

    # rename .spacemacs if switching between spacemacses
    if [[ ( ( $lcurr == "spacemacs" ) && ( $lnew == "spacemacs-vanilla" ) ) || ( ( $lcurr == "spacemacs-vanilla" ) && ( $lnew == "spacemacs" ) ) ]]; then
        mv ~/.spacemacs ~/.spacemacs.$_SE_SUFFIX.$lcurr
        [ $? -eq 0 ] && echo -n '.' || echo -n 'x'
        mv ~/.spacemacs.$_SE_SUFFIX.$lnew ~/.spacemacs
        [ $? ] && echo '.' || echo 'x'
    fi

    # tell about current emacs
    tput setaf $_SE_MAGENTA
    echo "CURRENT: ${lnew^^} ($snew)"
    figlet -f kban -w 160 ${lnew^^}
    tput sgr0
}
