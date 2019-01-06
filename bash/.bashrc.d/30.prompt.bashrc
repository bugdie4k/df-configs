#!/usr/bin/env bash

# This file is to be sourced

readonly _DF_PROMPT_COLOR_1=241
readonly _DF_PROMPT_COLOR_2=134
readonly _DF_PROMPT_COLOR_3=87
readonly _DF_PROMPT_COLOR_GREEN=2
readonly _DF_PROMPT_COLOR_RED=1
readonly _DF_PROMPT_COLOR_RESET='\[\e[0m\]'

readonly _DF_PROMPT_COLOR_RETCODE=$_DF_PROMPT_COLOR_1
readonly _DF_PROMPT_COLOR_USER=$_DF_PROMPT_COLOR_1
readonly _DF_PROMPT_COLOR_GIT=$_DF_PROMPT_COLOR_2
readonly _DF_PROMPT_COLOR_PATH=$_DF_PROMPT_COLOR_3
readonly _DF_PROMPT_COLOR_SHLVL=$_DF_PROMPT_COLOR_1
readonly _DF_PROMPT_COLOR_DOLLAR=$_DF_PROMPT_COLOR_1

function _df_prompt_shlvl {
  if [[ $SHLVL -gt 1 ]]; then
    for ((i=1; i<SHLVL; i++)); do
      printf '.'
    done
 fi
}

function _df_prompt_git_status {
  if git rev-parse --git-dir &>/dev/null; then
    local branch
    if ! git rev-parse HEAD &>/dev/null; then
      branch=∅
    else
      branch="$(git rev-parse --abbrev-ref HEAD)"
    fi
    branch="$(tput setaf $_DF_PROMPT_COLOR_GIT)$branch"
    if [[ $(git rev-parse --is-inside-git-dir) = 'true' ]]; then
      echo "$branch$(tput setaf $_DF_PROMPT_COLOR_RED).git "
      return
    fi
    if [[ $1 = 'only-branch' ]]; then
      echo "$branch "
      return
    fi
    local -a stats=($(
    git status --porcelain 2>/dev/null | awk '
BEGIN {
  untracked=0;
  unstaged=0;
  staged=0;
}
{
  if ($0 ~ /^\?\? .+/) {
    untracked += 1
  } else {
    if ($0 ~ /^.[^ ] .+/) {
      unstaged += 1
    }
    if ($0 ~ /^[^ ]. .+/) {
      staged += 1
    }
  }
}
END {
  print untracked " " unstaged " " staged
}
  '))
    local -r untracked="${stats[0]}"
    local -r unstaged="${stats[1]}"
    local -r staged="${stats[2]}"
    if [[ $untracked = '0' ]] && [[ $unstaged = '0' ]] && [[ $staged = '0' ]]; then
      echo "$branch$(tput setaf $_DF_PROMPT_COLOR_GREEN). "
      return
    fi
    local untracked_report unstaged_report staged_report
    [[ $untracked = '0' ]] &&
      untracked_report='' ||
      untracked_report="$(tput setaf $_DF_PROMPT_COLOR_RED)?$(tput setaf $_DF_PROMPT_COLOR_GIT)$untracked"
    [[ $unstaged = '0' ]] &&
      unstaged_report='' ||
      unstaged_report="$(tput setaf $_DF_PROMPT_COLOR_RED)+$(tput setaf $_DF_PROMPT_COLOR_GIT)$unstaged"
    [[ $staged = '0' ]] &&
      staged_report='' ||
      staged_report="$(tput setaf $_DF_PROMPT_COLOR_GREEN)*$(tput setaf $_DF_PROMPT_COLOR_GIT)$staged"
    echo "$branch$untracked_report$unstaged_report$staged_report "
    return
  fi
}

function _df_prompt_set_ps1 {
  local -r retcode="$(tput setaf $_DF_PROMPT_COLOR_RETCODE)\$?$_DF_PROMPT_COLOR_RESET"
  local -r user="$(tput setaf $_DF_PROMPT_COLOR_USER)\\u$_DF_PROMPT_COLOR_RESET"
  if [[ $DF_THIS_MACHINE = 'work' ]]; then
    local -r git_status_arg='only-branch'
  fi
  local -r git="$(tput setaf $_DF_PROMPT_COLOR_GIT)\$(_df_prompt_git_status $git_status_arg)$_DF_PROMPT_COLOR_RESET"
  local -r path="$(tput setaf $_DF_PROMPT_COLOR_PATH)\\w$_DF_PROMPT_COLOR_RESET"
  local -r shlvl="$(tput setaf $_DF_PROMPT_COLOR_SHLVL)$(_df_prompt_shlvl)$_DF_PROMPT_COLOR_RESET"
  # local -r dollar="$(tput setaf $_DF_PROMPT_COLOR_DOLLAR)\$$_DF_PROMPT_COLOR_RESET"
  PS1="$retcode $user $git$path $shlvl $(tput setaf $_DF_PROMPT_COLOR_DOLLAR)
\$ $_DF_PROMPT_COLOR_RESET"
  # tput on the second line messes up prompt
}

_df_prompt_set_ps1
