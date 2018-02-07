# -*- mode: shell-script -*-

# This file is to be sourced

# inspired by https://stackoverflow.com/questions/8455991/elegant-way-for-verbose-mode-in-scripts

###### settings

export LOG_LEVEL=7
export LOG_PREFIX=''

###### levels

# https://en.wikipedia.org/wiki/Syslog#Severity_level
declare -A LOG_LEVELS
LOG_LEVELS=([0]="emerg" [1]="alert" [2]="crit" [3]="err" [4]="warning" [5]="notice" [6]="info" [7]="debug")

###### functions

__get_level_prefix(){
    local res
    [[ $1 =~ ^[0-9]+$ ]] && res="${LOG_LEVELS[$1]^^}"
    [ -z "$res" ] && res="$1"
    echo -n "[$res] "
}

__.log_help(){
    echo "USAGE:"
    echo "  .log [-h|--help] [-l|--level LEVEL] [-f|--file FILE] [[-t|--text] TEXT]"
    echo
    echo "  --level specifies the severity level (https://en.wikipedia.org/wiki/Syslog#Severity_level)."
    echo "          Levels are:"
    echo "            0 - emerg"
    echo "            1 - alert"
    echo "            2 - crit"
    echo "            3 - err"
    echo "            4 - warning"
    echo "            5 - notice"
    echo "            6 - info"
    echo "            7 - debug"
    echo "          If none is specified level 6 (info) is assumed."
    echo "  --file  a file to output to. Default is to output to stdout."
    echo "  --text  text of a log message."
    echo
    echo "  When given an arg without an option assumes it is TEXT for log message."
    echo
    echo "CUSTOMIZATION VARS:"
    echo "  LOG_LEVEL - specifies maximum log level to output."
    echo "              .log outputs only if LEVEL specified with --level option is less then LOG_LEVEL."
    echo "              Default is LOG_LEVEL=6."
    echo "  LOG_PREFIX - specifies a prefix to put in front of all .log messages. By default is empty."
    echo
    echo "There're also functions "
    echo -e " .log-emerg\n .log-alert\n .log-crit\n .log-err\n .log-warning\n .log-notice\n .log-info\n .log-debug"
    echo "with the same usage but with LEVEL already being set."
    echo
}

.log(){
    local level=6
    local txt=''
    local file=''

    while [[ $# -gt 0 ]]
    do
        case $1 in
            -l|--level) level=$2; shift ;;
            -f|--file)  file=$2; shift ;;
            -t|--text)  txt="$2"; shift ;;
            -h|--help)  __.log_help && return 0 ;;
            *)
                # if arg passed with no preceding option -
                # assume it is text
                local txt="$@"
                break
                ;;
        esac
        shift
    done

    if [ $level -le $LOG_LEVEL ]; then
        if [ -n "$file" ]; then
            echo "${LOG_PREFIX}$(__get_level_prefix $level)${txt}" >> "$file"
        else
            echo "${LOG_PREFIX}$(__get_level_prefix $level)${txt}"
        fi
    fi
}

.log-emerg(){
    .log -l 0 "$@"
}

.log-alert(){
    .log -l 1 "$@"
}

.log-crit(){
    .log -l 2 "$@"
}

.log-err(){
    .log -l 3 "$@"
}

.log-warning(){
    .log -l 4 "$@"
}

.log-notice(){
    .log -l 5 "$@"
}

.log-info(){
    .log -l 6 "$@"
}

.log-debug(){
    .log -l 7 "$@"
}
