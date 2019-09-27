#!/usr/bin/env bash

# L I M - link maker

# This file is a "library" and is to be sourced.

# Provides functions
# - lim
# - lim_summary

# Configuration variables
# - LIM_TARGP
# - LIM_LINKP
# - LIM_ACTION

# Actions are
# - link
# - copy (not implemented yet)
# - remove
# - skip

# Author: Danylo Fedorov

# ---

# Action return codes
# - 0  - All ok
# - 5  - Declaration error
# - 10 - Generic error
# - 20 - Action not performed because of interactive choice
# - 30 - Action not performed because of pre-existing success state
# ('already exists' for 'link' action or 'already does not exist' for 'remove')

function echo_nf {
  tput setaf "$1"
  shift
  echo -n "$@"
  tput sgr0
}

function echo_f {
  echo_nf "$@"
  echo
}

function echo_nb {
  tput setab "$1"
  shift
  echo -n "$@"
  tput sgr0
}

function echo_b {
  echo_nb "$@"
  echo
}

function echo_nfb {
  tput setaf "$1"
  shift
  tput setab "$1"
  shift
  echo -n "$@"
  tput sgr0
}

function echo_fb {
  echo_nfb "$@"
  echo
}

function _install_file {
  local -ri sudo="$1"
  local -r  action="$2"
  local -r  target="$3"
  local -r  link_or_copypath="$4"

  case "$action" in
    link)
      if [[ $sudo -eq 1 ]]; then
        sudo ln -sv "$target" "$link_or_copypath"
        return $?
      else
        ln -sv "$target" "$link_or_copypath"
        return $?
      fi
      ;;
    copy)
      if [[ $sudo -eq 1 ]]; then
        sudo cp -v "$target" "$link_or_copypath"
        return $?
      else
        cp -v "$target" "$link_or_copypath"
        return $?
      fi
      ;;
    *)
      return 10
      ;;
   esac
}

function _rm_file {
  local -ri sudo="$1"
  local -r  file="$2"

  if [[ $sudo -eq 1 ]]; then
    sudo rm -v "$file"
    return $?
  else
    rm -v "$file"
    return $?
  fi
}

function _mkdirp {
  local -ri sudo="$1"
  local -r  dirname="$2"

  if [[ $sudo -eq 1 ]]; then
    sudo mkdir -p "$dirname"
    return $?
  else
    mkdir -p "$dirname"
    return $?
   fi
}

function _lim_install_link_broken_link {
  local -r  target="$1"
  local -r  link="$2"
  local -ri sudo="$3"

  local -r existing_link_target=$(readlink "$link")
  echo "Broken symbolic link: $link -> $existing_link_target"
  local -r existing_link_target_basename=$(basename "$existing_link_target")
  local -r target_basename=$(basename "$target")
  if [[ $existing_link_target_basename = "$target_basename" ]]; then
    echo_f 2 "Broken link points to a path with the same basename as target: $existing_link_target_basename"
    echo "Current target: $existing_link_target"
    echo "New target:     $target"
    local choice
    read -r -p 'Change target from current to new? [y/N] ' choice
    case "$choice" in
      y|Y)
        echo_f 2 "Changing it!"
        _rm_file "$sudo" "$link" &&
          _install_file "$sudo" link "$target" "$link"
        return $?
        ;;
      *)
        echo_f 3 "Do nothing"
        return 20
        ;;
    esac
  fi
  return 10
}

function _lim_install_no_dir {
  local -r  action="$1"
  local -r  target="$2"
  local -r  link_or_copypath="$3"
  local -r  dirname="$4"
  local -ri sudo="$5"

  echo "Dir does not exist: $dirname"
  local choice
  read -r -p 'Create this dir? [y/N] ' choice
  case "$choice" in
    Y|y)
      echo_f 2 "Creating '$dirname'!"
      _mkdirp "$sudo" "$dirname" &&
        _install_file "$sudo" "$action" "$target" "$link_or_copypath"
      return $?
      ;;
    *)
      echo_f 3 "Do nothing"
      return 20
      ;;
  esac
}

function _lim_install_doesnt_exist {
  local -r  action="$1"
  local -r  target="$2"
  local -r  link_or_copypath="$3"
  local -ri sudo="$4"

  return $?
}

function _lim_install_exists {
  local -r  action="$1"
  local -r  target="$2"
  local -r  link_or_copypath="$3"
  local -ri sudo="$4"

  echo "File exists: $link_or_copypath"
  if [[ -L "$link_or_copypath" ]]; then
    local -r existing_link_target=$(readlink "$link_or_copypath")
    echo "File is a link to $existing_link_target"
    if [[ "$existing_link_target" = "$target" ]]; then
      echo No need to install, alredy points to target
      return 30
    else
      echo "Need to manually check the link: $link_or_copypath -> $existing_link_target"
      return 10
    fi
  elif [[ -f "$link_or_copypath" ]]; then
    echo File is a regular file
    if diff "$link_or_copypath" "$target"; then
      echo_f 2 "But there is no diff!"

      if [[ $action = 'copy' ]]; then
        return
      fi

      local choice
      read -r -p "Remove it and make a link? [y/N] " choice
      case "$choice" in
        Y|y)
          echo_f 2 "Replacing it with a link!"
          _rm_file "$sudo" "$link_or_copypath" &&
            _install_file "$sudo" link "$target" "$link_or_copypath" 
          ;;
        *)
          echo_f 3 "Do nothing"
          return 20
          ;;
      esac
    else
      echo_f 1 "There is a diff!"
      echo "Existing file: $link_or_copypath"
      echo "Target:        $target"
      return 10
    fi
  else
    echo "Unexpected file type, need manual check: $(file $link_or_copypath)"
    return 10
  fi
}

function _check_target_exists {
  local -r target="$1"

  if [[ ! -e $target ]]; then
    echo "Target does not exist: $target"
    return 10
  fi
}

function _is_broken_link {
  local -r file="$1"

  if [[ ! -e "$file" ]] && [[ -L "$file" ]]; then
    return 0
  else
    return 1
  fi
}

function _lim_install {
  local -ri sudo="$1"
  local -r  action="$2"
  local -r  target="$3"
  local -r  link_or_copypath="$4"

  if [[ $action = 'link' ]]; then
    echo -n 'L> '
  else
    echo -n 'C> '
  fi 
  echo_nb 4 "$link_or_copypath"
  echo -n ' -> '
  echo_fb 0 12 "$target"

  _check_target_exists "$target" || return $?

  local -r link_dirname="$(dirname $link_or_copypath)"

    echo I AM HERER
  if _is_broken_link "$link_or_copypath"; then
    if [[ $action = 'link' ]]; then
      _lim_install_link_broken_link "$target" "$link_or_copypath" "$sudo"
      return $?
    else
      local -r existing_link_target=$(readlink "$link_or_copypath")
      echo "Broken symbolic link: $link_or_copypath -> $existing_link_target"
      return 10
    fi
  elif [[ ! -e $link_dirname ]]; then
    _lim_install_no_dir "$action" "$target" "$link_or_copypath" "$link_dirname" "$sudo"
    return $?
  elif [[ ! -e $link_or_copypath ]];  then
    _install_file "$sudo" "$action" "$target" "$link_or_copypath"
    return $?
  else
    _lim_install_exists "$action" "$target" "$link_or_copypath" "$sudo"
    return $?
  fi
}

function _lim_remove {
  local -ri sudo="$1"
  local -r  target=$2
  local -r  link_or_copypath="$3"

  echo -n 'R> '
  echo_b 4 "$link_or_copypath"

  if [[ ! -e $link_or_copypath ]]; then
    echo "Doesn't exist: $link_or_copypath"
    return 30
  fi

  if [[ ! -L $link_or_copypath ]]; then
    echo_f 1 "Cannot remove because is not a link, but a real file: $link_or_copypath"
    ls -la "$link_or_copypath"
    return 10
  fi

  _rm_file "$sudo" "$link_or_copypath"
  return $?
}

function _lim_skip {
  local -r  target=$1
  local -r  link_or_copypath="$2"

  echo -n 'S> '
  echo_nfb 0 8 "$link_or_copypath"
  echo -n ' -> '
  echo_fb 0 8 "$target"
  return 0
}

# to pass things around when executing entry
declare    __LIM_ENTRY_TARGET
declare    __LIM_ENTRY_LINK_OR_COPYPATH
declare    __LIM_ENTRY_ACTION
declare -i __LIM_ENTRY_SUDO

function _lim_parse_input {
  local name target link_or_copypath action sudo

  sudo=0

  while [[ $# -ne 0 ]]; do
    case "$1" in
      -NAME) name="$2"; shift ;;
      -TARGET) target="$2"; shift ;;
      -LINK) link_or_copypath="$2"; shift ;;
      -COPY) link_or_copypath="$2"; action='copy'; shift ;;
      -ACTION) action="$2"; shift ;;
      -SUDO) sudo=1 ;;
      *) echo_f 1 "Unknown option: $1"; return 5 ;;
    esac
    shift;
  done

  if [[ ! -z $LIM_TARGP ]]; then
    target="${LIM_TARGP%/}/$target"
  fi

  if [[ ! -z $LIM_LINKP ]]; then
    link_or_copypath="${LIM_LINKP%/}/$link_or_copypath"
  fi

  if [[ -z $target ]]; then
    echo_f 1 "Cannot determine a target!"
    return 5
  fi

  if [[ -z $link_or_copypath ]]; then
    echo_f 1 "Cannot determine a link or a copypath!"
    return 5
  fi

  if [[ ! -z $name ]]; then
    target="${target%/}/$name"
    link_or_copypath="${link_or_copypath%/}/$name"
  fi

  if [[ -z $action ]]; then
    if [[ -z $LIM_ACTION ]]; then
      echo_f 1 "Cannot determine an action!"
      return 5
    fi
    action=$LIM_ACTION
  fi

  __LIM_ENTRY_TARGET=$target
  __LIM_ENTRY_LINK_OR_COPYPATH=$link_or_copypath
  __LIM_ENTRY_ACTION=$action
  __LIM_ENTRY_SUDO=$sudo
}

function _lim_perform_action {
  local -r action=$__LIM_ENTRY_ACTION
  local -r target=$__LIM_ENTRY_TARGET
  local -r link_or_copypath=$__LIM_ENTRY_LINK_OR_COPYPATH
  local -r sudo=$__LIM_ENTRY_SUDO

  case $action in
    link)
      _lim_install "$sudo" link "$target" "$link_or_copypath"
      return $?
      ;;
    copy)
      _lim_install "$sudo" copy "$target" "$link_or_copypath"
      return $?
      ;;
    remove)
      _lim_remove "$sudo" "$target" "$link_or_copypath" 
      return $?
      ;;
    skip)
      _lim_skip "$target" "$link_or_copypath"
      return $?
      ;;
    *)
      echo_f 1 "?> target=$target link=$link action=$action sudo=$sudo"
      echo_f 1 "Unknown action: $action"
      return 5
      ;;
  esac
}

declare -i COUNT=0

declare -i DECLARATION_ERRORS=0

declare -i INSTALLED=0
declare -i NOT_INSTALLED=0
declare -i EXISTING=0

declare -i REMOVED=0
declare -i NOT_REMOVED=0
declare -i NOT_EXISTING=0

declare -i SKIPPED=0

declare -i ERRORS=0

function _lim_report_action {
  local -r action=$__LIM_ENTRY_ACTION

  local -ri retcode=$1

  COUNT+=1

  if [[ $retcode -eq 5 ]]; then
    echo_b 1 "DECLARATION ERROR"
    DECLARATION_ERRORS+=1
    return
  fi

  case $action in
    link)
      case $retcode in
        0)
          echo_fb 0 10 "LINK CREATED"
          INSTALLED+=1
          return
          ;;
        20)
          echo_fb 0 3 "LINK IS NOT CREATED"
          NOT_INSTALLED+=1
          return
          ;;
        30)
          echo_f 2 "LINK ALREADY EXISTS"
          EXISTING+=1
          return
          ;;
      esac
      ;;
    copy)
      # TODO: implement
      return
      ;;
    remove)
      case $retcode in
        0)
          echo_fb 0 10 "REMOVED"
          REMOVED+=1
          return
          ;;
        20)
          echo_fb 0 3 "NOT REMOVED"
          NOT_REMOVED+=1
          return
          ;;
        30)
          echo_f 2 "ALREADY DOESN'T EXIST"
          NOT_EXISTING+=1
          return
          ;;
      esac
      ;;
    skip)
      if [[ $retcode -eq 0 ]]; then
        echo_fb 0 8 "SKIPPED"
        SKIPPED+=1
        return
      else
        echo_b 1 "NOT SKIPPED?"
        ERRORS+=1
      fi
      ;;
    *)
      echo_b 1 '!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
      echo_b 1 'Exception: Unhandled action!'
      echo_b 1 '!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
      return
      ;;
  esac

  echo_b 1 "ERROR"
  ERRORS+=1
}

function lim {
  _lim_parse_input "$@"
  _lim_perform_action "$@"
  _lim_report_action $?
}

function lim_summary {
  echo
  echo_b 5 "Summary"

  function report {
    printf "  %-16s $(tput setaf $2)% 2s$(tput sgr0) / $COUNT\n" "$1" "$3"
  }

  if [[ $DECLARATION_ERRORS -gt 0 ]]; then
    report 'BAD DECLARATIONS' 1 $DECLARATION_ERRORS
  fi

  if [[ $INSTALLED -gt 0 ]] || [[ $NOT_INSTALLED -gt 0 ]] || [[ $EXISTING -gt 0 ]]; then
    echo 'I>'
    if [[ $INSTALLED -gt 0 ]]; then
      report 'Installed' 10 $INSTALLED
    fi
    if [[ $NOT_INSTALLED -gt 0 ]]; then
      report 'Not installed' 3 $NOT_INSTALLED
    fi
    if [[ $EXISTING -gt 0 ]]; then
      report 'Existing' 2 $EXISTING
    fi
  fi

  if [[ $REMOVED -gt 0 ]] || [[ $NOT_REMOVED -gt 0 ]] || [[ $NOT_EXISTING -gt 0 ]]; then
    echo 'R>'
    if [[ $REMOVED -gt 0 ]]; then
      report 'Removed' 10 $REMOVED
    fi
    if [[ $NOT_REMOVED -gt 0 ]]; then
      report 'Not removed' 3 $NOT_REMOVED
    fi
    if [[ $NOT_EXISTING -gt 0 ]]; then
      report 'Not existing' 2 $NOT_EXISTING
    fi
  fi

  if [[ $SKIPPED -gt 0 ]]; then
    echo 'S>'
    report 'Skipped' 8 $SKIPPED
  fi

  if [[ $ERRORS -gt 0 ]]; then
    report 'ERRORS' 1 $ERRORS
  fi
  if [[ $ERRORS -eq 0 ]] && [[ $DECLARATION_ERRORS -eq 0 ]]; then
    echo_b 2 "All ok"
  else
    echo_b 1 "Examine errors in the log!"
  fi
}
