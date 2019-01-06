#!/usr/bin/env bash

CONFIGS_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
readonly CONFIGS_DIR

function broken_link {
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

function link_exists {
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

function install_aux {
  local -r target="$1"
  local -r link="$2"

  echo "$(tput setab 4)$link -> $target$(tput sgr0)"
  if [[ ! -e $target ]]; then
    echo "Target does not exist: $target"
    return 10
  elif [[ ! -e $link ]] && [[ -L $link ]]; then
    broken_link "$target" "$link"
    return $?
  elif [[ ! -e $link ]];  then
    ln -sv "$target" "$link"
    return $?
  else
    link_exists "$target" "$link"
    return $?
  fi
}

declare -i COUNT=0
declare -i EXISTING=0
declare -i ERRORS=0
declare -i NOT_INSTALLED=0
declare -i INSTALLED=0

function install {
  install_aux "$@"
  local -ri retcode=$?
  COUNT+=1
  if [[ $retcode -eq 0 ]]; then
    echo "$(tput setab 10)$(tput setaf 0)INSTALLED$(tput sgr0)"
    INSTALLED+=1
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

function report_summary {
  echo
  echo "$(tput setab 4)Summary$(tput sgr0)"
  function report {
    printf "%-15s $(tput setaf $2)% 2s$(tput sgr0) / $COUNT\n" "$1" "$3"
  }
  if [[ $INSTALLED -gt 0 ]]; then
    report Installed 10 $INSTALLED
  fi
  if [[ $EXISTING -gt 0 ]]; then
    report Existing 2 $EXISTING
  fi
  if [[ $NOT_INSTALLED -gt 0 ]]; then
    report "Not installed" 3 $NOT_INSTALLED
  fi
  if [[ $ERRORS -gt 0 ]]; then
    report ERRORS 1 $ERRORS
  fi
  if [[ $ERRORS -eq 0 ]]; then
    echo "$(tput setab 2)All ok$(tput sgr0)"
  else
    echo "$(tput setab 1)Examine errors in the log!$(tput sgr0)"
  fi
}

# bash
install "$CONFIGS_DIR/bash/.bash_profile" ~/.bash_profile
install "$CONFIGS_DIR/bash/.bashrc" ~/.bashrc
install "$CONFIGS_DIR/bash/.bashrc.d" ~/.bashrc.d
# x-settings
install "$CONFIGS_DIR/x-settings/.xinitrc" ~/.xinitrc
install "$CONFIGS_DIR/x-settings/xorg.conf" /etc/X11/xorg.conf
# apt
# install "$CONFIGS_DIR/apt/99df-apt-configs" /etc/apt/apt.conf.d/99df-apt-configs
# install "$CONFIGS_DIR/apt/df-sources.list" /etc/apt/sources.list.d/df-sources.list
# vim
install "$CONFIGS_DIR/vim/.vimrc" ~/.vimrc
install "$CONFIGS_DIR/vim/gvim-client-or-server" ~/bin/gvim-client-or-server
# emacs
install "$CONFIGS_DIR/emacs/emacs-client-or-daemon" ~/bin/emacs-client-or-daemon
install "$CONFIGS_DIR/emacs/init.el" ~/.emacs.d/init.el
# git
install "$CONFIGS_DIR/git/.gitconfig" ~/.gitconfig
install "$CONFIGS_DIR/git/git-scripts/git-dh" ~/bin/git-dh
install "$CONFIGS_DIR/git/git-scripts/git-s" ~/bin/git-s
install "$CONFIGS_DIR/git/git-scripts/git-ss" ~/bin/git-ss
install "$CONFIGS_DIR/git/git-scripts/git-sst" ~/bin/git-sst
install "$CONFIGS_DIR/git/git-scripts/git-fix" ~/bin/git-fix
# ranger
install "$CONFIGS_DIR/ranger/rc.conf" ~/.config/ranger/rc.conf
install "$CONFIGS_DIR/ranger/scope.sh" ~/.config/ranger/scope.sh
install "$CONFIGS_DIR/ranger/rifle.conf" ~/.config/ranger/rifle.conf
install "$CONFIGS_DIR/ranger/commands.py" ~/.config/ranger/commands.py
# awesome
install "$CONFIGS_DIR/awesome/rc.lua" ~/.config/awesome/rc.lua
install "$CONFIGS_DIR/awesome/df-theme" ~/.config/awesome/themes/df-theme
install "$CONFIGS_DIR/awesome/df-awesome-startup" ~/.config/awesome/df-awesome-startup
# bin
install "$CONFIGS_DIR/bin/df-lockscreen" ~/bin/df-lockscreen

report_summary

