# -*- mode: shell-script -*-

# This file is to be sourced

. ${CONFIGS}/bash/functions.switch-emacs.bash

function qbc (){
    : "quick bc"

    echo "$@" | bc -l
}

function gi(){
    : "generates gitignore file based on the input, needs internet connection"
    : "run 'gi list' to see possble arguments"

    curl -L -s https://www.gitignore.io/api/$@ ;
}

function indent-with(){
    : "works with piped stream"
    : "example: echo -e line 1\\nline 2\\n3\\n4\\n5\\nOPANA | indent-with '>>>'"

    sed "s/^/$1/"
}

function fibo(){
    : "fibonacci numbers (yes, it is useless)"

    local -i acc
    local -ir n=${1:-0}
    [ $n -eq 0 ] && return 0
    [ $n -lt 0 ] && { echo-color -f red "amount can't be < 0, man"; return 1; }
    [ $n -le 2 ] && echo-color -f yellow "nums <= 2 are useless, man"
    [ $n -gt 0 ] && acc[0]=0
    [ $n -gt 1 ] && acc[1]=1
    for ((i=2; i<$n; i++)); do
        acc[$i]=$(qbc ${acc[$[i - 2]]} + ${acc[$[i - 1]]})
    done
    echo -ne ${acc[*]+"${acc[*]}\n"}
}

function mdcd(){
    : "create dirs and cd to the last of them"

    mkdir -p $@
    cd ${@: -1}
}

function dot2png(){
    : "converts given dot file to png and opens it. (needs graphviz)"

    name="${1%.*}"
    dot -Tpng -o ${name}.png ${name}.dot && eog ${name}.png
}

# volume control
function setvol(){
    : "arg is either +n or -n where n is volume %"

    case "$1" in
        mute) pactl -- set-sink-mute 0 1 ;;
        unmute) pactl -- set-sink-mute 0 0 ;;
        toggle-mute) pactl -- set-sink-mute 0 toggle ;;
        *) pactl -- set-sink-volume 0 "$1%" ;;
    esac
}

function xautolock-disable-for(){
    : "disable xautolock for time"

    if [ $# -eq 0 ] || [ "$1" = "ever" ]; then
        xautolock -disable
    else
        xautolock -disable && sleep "${1}m" && xautolock -enable &
    fi
}

function cpwd(){
    : "copy pwd with no newline at the end"

    if [ $# -eq 0 ]; then
        local -r tocopy="$(pwd)"
    else
        local -r tocopy="$(pwd)/$1"
    fi
    echo COPIED $tocopy
    echo -n $tocopy | xclip -selection clipboard
}

function wd() {
    local -r output=$(_wd $@)
    local -r ret=$?

    if [[ $ret -eq 0  ]]
    then
        cd "$output"
    else
        if [[ "$output" != "" ]]
        then
            echo "$output"
        fi
    fi
}

function ep () {
    : "emacs with selecting recent files from fasd with fzf"

    file_to_open=$(fasd -f -R | fzf --preview "__ep_preview {}" | awk -F ' ' '{print $2}')
    if [ -n "$file_to_open" ]; then
        emacs-client-or-daemon.sh "$file_to_open"
    else
        echo "ep: nothing happened"
    fi
}

function cc () {
    : "cd selecting recent dirs from fasd with fzf"

    dir_to_open=$(fasd -d -R | fzf --preview "__ep_preview {}" | awk -F ' ' '{print $2}')
    if [ -n "$dir_to_open" ]; then
        cd "$dir_to_open"
    else
        echo "cc: nothing happened"
    fi
}
