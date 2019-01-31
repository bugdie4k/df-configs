#!/usr/bin/env bash

# L I M - link maker

# This file is a "library" to be sourced

# Provides the 'lim' and 'lim_report' functions
# and a possibility to configure them through vars
# TARG_PREF and LINK_PREF

# Author: Danylo Fedorov

function _lim_install_broken_link {
  local -r target="$1"
  local -r link="$2"

  local -r existing_link_target=$(readlink "$link")
  echo "Broken symbolic link: $link -> $existing_link_target"
  local -r existing_link_target_basename=$(basename "$existing_link_target")
  local -r target_basename=$(basename "$target")
  if [[ $existing_link_target_basename = "$target_basename" ]]; then
    echo "$(tput setaf 2)Broken link points to a path with the same basename as target: $existing_link_target_basename$(tput sgr0)"
    echo "Current target: $existing_link_target"
    echo "New target:     $target"
    local choice
    read -r -p 'Change target from current to new? [y/N] ' choice
    case "$choice" in
      y|Y)
        echo "$(tput setaf 2)Changing it!$(tput sgr0)"
        rm -v "$link"
        ln -sv "$target" "$link"
        return $?
        ;;
      *)
        echo "$(tput setaf 3)Do nothing$(tput sgr0)"
        return 20
        ;;
    esac
  fi
  return 10
}

function _lim_install_link_exists {
  local -r target="$1"
  local -r link="$2"
  echo "File exists: $link"
  if [[ -L "$link" ]]; then
    local -r existing_link_target=$(readlink "$link")
    echo "File is a link to $existing_link_target"
    if [[ "$existing_link_target" = "$target" ]]; then
      echo No need to install, alredy points to target
      return 30
    else
      echo "Need to manually check the link: $link -> $existing_link_target"
      return 10
    fi
  elif [[ -f "$link" ]]; then
    echo File is a regular file
    if diff "$link" "$target"; then
      echo "$(tput setaf 2)But there is no diff!$(tput sgr0)"
      local choice
      read -r -p 'Remove it and make a link? [y/N] ' choice
      case "$choice" in
        Y|y)
          echo "$(tput setaf 2)Replacing it with a link!$(tput sgr0)"
          rm -v "$link"
          ln -sv "$target" "$link"
          return $?
          ;;
        *)
          echo "$(tput setaf 3)Do nothing$(tput sgr0)"
          return 20
          ;;
      esac
    else
      echo "$(tput setaf 1)There is a diff!$(tput sgr0)"
      echo "Existing file: $link"
      echo "Target:        $target"
      return 10
    fi
  else
    echo "Unexpected file type, need manual check: $(file $link)"
    return 10
  fi
}

function _lim_install {
  local -r target="$1"
  local -r link="$2"

  echo "$(tput setab 4)$link -> $target$(tput sgr0)"
  if [[ ! -e $target ]]; then
    echo "Target does not exist: $target"
    return 10
  elif [[ ! -e $link ]] && [[ -L $link ]]; then
    _lim_install_broken_link "$target" "$link"
    return $?
  elif [[ ! -e $link ]];  then
    ln -sv "$target" "$link"
    return $?
  else
    _lim_install_link_exists "$target" "$link"
    return $?
  fi
}

function _lim_aux {
  local name target link
  while [[ $# -ne 0 ]]; do
    case $1 in
      -n|-N|-name|-NAME) name=$2 ;;
      -t|-T|-target|-TARGET) target=$2 ;;
      -l|-L|-link|-LINK) link=$2 ;;
      *) echo "$(tput setaf 1)Unknown option: $1$(tput sgr0)"; return 5 ;;
    esac
    shift; shift
  done

  if [[ ! -z $TARG_PREF ]]; then
    target="${TARG_PREF%/}/$target"
  fi

  if [[ ! -z $LINK_PREF ]]; then
    link="${LINK_PREF%/}/$link"
  fi

  if [[ -z $target ]]; then
    echo "$(tput setaf 1)Cannot determine a target!$(tput sgr0)"
    return 5
  fi

  if [[ -z $link ]]; then
    echo "$(tput setaf 1)Cannot determine a link!$(tput sgr0)"
    return 5
  fi

  if [[ ! -z $name ]]; then
    target="${target%/}/$name"
    link="${link%/}/$name"
  fi

  _lim_install "$target" "$link"
  return $?
}

declare -i COUNT=0
declare -i INSTALLED=0
declare -i DECLARATION_ERRORS=0
declare -i NOT_INSTALLED=0
declare -i EXISTING=0
declare -i ERRORS=0

function lim {
  _lim_aux "$@"
  local -ri retcode=$?
  COUNT+=1
  if [[ $retcode -eq 0 ]]; then
    echo "$(tput setab 10)$(tput setaf 0)INSTALLED$(tput sgr0)"
    INSTALLED+=1
  elif [[ $retcode -eq 5 ]]; then
    echo "$(tput setab 1)DECLARATION ERROR$(tput sgr0)"
    DECLARATION_ERRORS+=1
  elif [[ $retcode -eq 20 ]]; then
    echo "$(tput setab 3)$(tput setaf 0)NOT INSTALLED$(tput sgr0)"
    NOT_INSTALLED+=1
  elif [[ $retcode -eq 30 ]]; then
    echo "$(tput setab 2)EXISTS$(tput sgr0)"
    EXISTING+=1
  else
    echo "$(tput setab 1)ERROR$(tput sgr0)"
    ERRORS+=1
  fi
}

function lim_report {
  echo
  echo "$(tput setab 4)Summary$(tput sgr0)"
  function report {
    printf "%-16s $(tput setaf $2)% 2s$(tput sgr0) / $COUNT\n" "$1" "$3"
  }
  if [[ $INSTALLED -gt 0 ]]; then
    report 'Installed' 10 $INSTALLED
  fi
  if [[ $DECLARATION_ERRORS -gt 0 ]]; then
    report 'BAD DECLARATIONS' 1 $DECLARATION_ERRORS
  fi
  if [[ $EXISTING -gt 0 ]]; then
    report 'Existing' 2 $EXISTING
  fi
  if [[ $NOT_INSTALLED -gt 0 ]]; then
    report 'Not installed' 3 $NOT_INSTALLED
  fi
  if [[ $ERRORS -gt 0 ]]; then
    report 'ERRORS' 1 $ERRORS
  fi
  if [[ $ERRORS -eq 0 ]] && [[ $DECLARATION_ERRORS -eq 0 ]]; then
    echo "$(tput setab 2)All ok$(tput sgr0)"
  else
    echo "$(tput setab 1)Examine errors in the log!$(tput sgr0)"
  fi
}
