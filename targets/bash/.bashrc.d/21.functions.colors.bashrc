#!/usr/bin/env bash

# This file is to be sourced

function colors {
  for ((i=0; i<16; i++)); do
    printf "$(df__ini_tput setaf $i)%3d $(df__ini_tput setab $i)   $(df__ini_tput sgr0)" $i
    [[ ! $(((i + 1) % 8)) -eq 0 ]] && echo -n '  ' || echo
  done
}

function colorsgray {
  for ((i=232; i<256; i++)); do
    printf "$(df__ini_tput setaf $i)%3d $(df__ini_tput setab $i)   $(df__ini_tput sgr0)" $i
    [[ ! $(((i - 15) % 6)) -eq 0 ]] && printf '  ' || printf '\n'
  done
}

function colorsall {
  printf '0-15:\n'
  colors

  local num
  for ((i=0; i<3; i++)); do
    num=$((16 + (i * 72)))
    printf '\n%-54s%s\n' "$num-$((num + 35)):" "$((num + 36))-$((num + 36 + 35)):"
    for ((j=0; j<6; j++)); do
      for ((k=0; k<6; k++)); do
        num=$((16 + (i * 72) + (j * 6) + k))
        printf "$(df__ini_tput setaf $num)%3d $(df__ini_tput setab $num)   $(df__ini_tput sgr0)  " $num
      done
      for ((k=0; k<6; k++)); do
        num=$((16 + (i * 72) + (j * 6) + k + 36))
        printf "$(df__ini_tput setaf $num)%3d $(df__ini_tput setab $num)   $(df__ini_tput sgr0)  " $num
      done
      echo
    done
  done

  printf '\n232-255\n'
  colorsgray
}
