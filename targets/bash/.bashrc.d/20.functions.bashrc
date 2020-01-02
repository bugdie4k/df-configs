#!/usr/bin/env bash

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

function sho {
  if [[ $# -eq 0 ]]; then
    echo "$(tput setaf 1)sho: $(tput bold)No arguments$(tput sgr0)"
    return 1
  fi
  local retcode=0
  for arg in "$@"; do
    if [[ ! -e $arg ]]; then
      echo "$(tput setaf 1)sho: $(tput bold)There is no $arg$(tput sgr0)"
      retcode=1
      continue
    fi
    if [[ $# -gt 1 ]]; then
      echo "$(tput setaf 5)sho: $(tput bold)$arg$(tput sgr0)"
    fi
    if [[ -d $arg ]]; then
      /usr/bin/env ls -aFhl --color "$arg"
    else
      highlight --out-format xterm256 --style "$DF_HIGHLIGHT_STYLE" "$arg" 2>/dev/null || cat "$arg"
    fi
    if [[ $# -gt 1 ]]; then
      echo
    fi
  done
  return $retcode
}

function j {
  if [[ $# -ne 0 ]]; then
    cd $(autojump "$@") || return 1
    return
  fi
  cd "$(autojump -s | sed '/_____/Q; s/^[0-9,.:]*\s*//' |  fzf --height 40% --reverse --inline-info)" || return 1
}

# set the terminal window name
function setname {
  echo -ne "\033]0;$1\007"
}
