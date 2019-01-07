# -*- mode: shell-script -*-
# vi:syntax=sh

# This file is to be sourced

function = {
  local calc="${*//p/+}"
  calc="${calc//x/*}"
  bc -l <<< "scale=10;$calc"
}

function gi {
  : "generates gitignore file based on the input, needs internet connection"
  : "run 'gi list' to see possble arguments"
  curl -L -s "https://www.gitignore.io/api/$*"
}

function mdcd {
  mkdir -p "$1"
  cd "$1" || return
}

function dot2png {
  : "converts given dot file to png and opens it. (needs graphviz)"
  local -r name="${1%.*}"
  dot -Tpng -o "${name}.png" "${name}.dot" && eog "${name}.png"
}

function setvol {
  case "$1" in
    mute) pactl -- set-sink-mute 0 1 ;;
    unmute) pactl -- set-sink-mute 0 0 ;;
    toggle-mute) pactl -- set-sink-mute 0 toggle ;;
    *) pactl -- set-sink-volume 0 "$1%" ;;
  esac
}

function xautolock-disable-for {
  if [[ $# -eq 0 ]] || [[ "$1" = "ever" ]]; then
    xautolock -disable
  else
    xautolock -disable && sleep "${1}m" && xautolock -enable &
  fi
}

function cpwd {
  if [[ $# -eq 0 ]]; then
    local -r tocopy="$(pwd)"
  else
    local -r tocopy="$(pwd)/$1"
  fi
  echo COPIED "$tocopy"
  echo -n "$tocopy" | xclip -selection clipboard
}



