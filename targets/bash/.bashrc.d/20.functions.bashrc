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
  local -r sinkname="alsa_oudf__ini_tput.pci-0000_00_1f.3.analog-stereo"
  case "$1" in
    mute) pactl -- set-sink-mute $sinkname 1 ;;
    unmute) pactl -- set-sink-mute $sinkname 0 ;;
    toggle-mute) pactl -- set-sink-mute $sinkname toggle ;;
    *) pactl -- set-sink-volume $sinkname "$1%" ;;
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
    echo "$(df__ini_tput setaf 1)sho: $(df__ini_tput bold)No arguments$(df__ini_tput sgr0)"
    return 1
  fi
  local retcode=0
  for arg in "$@"; do
    if [[ ! -e $arg ]]; then
      echo "$(df__ini_tput setaf 1)sho: $(df__ini_tput bold)There is no $arg$(df__ini_tput sgr0)"
      retcode=1
      continue
    fi
    if [[ $# -gt 1 ]]; then
      echo "$(df__ini_tput setaf 5)sho: $(df__ini_tput bold)$arg$(df__ini_tput sgr0)"
    fi
    if [[ -d $arg ]]; then
      /usr/bin/env ls -aFhl --color "$arg"
    else
      # highlight --out-format xterm256 --style "$DF_HIGHLIGHT_STYLE" "$arg" 2>/dev/null || cat "$arg"
      batcat -p "$@"
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
function twn {
  echo -ne "\033]0;$1\007"
}

function wsp {
  webstorm "$1" &> /dev/null &
}
