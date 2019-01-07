# -*- mode: shell-script -*-
# vi:syntax=sh

# This file is to be sourced

readonly _DF_PROMPT_COLOR1=4
readonly _DF_PROMPT_COLOR2=3
readonly _DF_PROMPT_COLOR_GREEN=2
readonly _DF_PROMPT_COLOR_RED=1
readonly _DF_PROMPT_COLOR_RESET='\[\e[0m\]'

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
    branch="$(tput setaf $_DF_PROMPT_COLOR2)$branch"
    if [[ $1 = 'only-branch' ]]; then
      echo "$branch "
      return
    fi
    local -a stats=($(
    git status --porcelain | awk '
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
      echo "$branch$(tput setaf $_DF_PROMPT_COLOR_GREEN).$(tput setaf $_DF_PROMPT_COLOR2) "
      return
    fi
    local untracked_report unstaged_report staged_report
    [[ $untracked = '0' ]] &&
      untracked_report='' ||
      untracked_report="$(tput setaf $_DF_PROMPT_COLOR_RED)?$(tput setaf $_DF_PROMPT_COLOR2)$untracked"
    [[ $unstaged = '0' ]] &&
      unstaged_report='' ||
      unstaged_report="$(tput setaf $_DF_PROMPT_COLOR_RED)+$(tput setaf $_DF_PROMPT_COLOR2)$unstaged"
    [[ $staged = '0' ]] &&
      staged_report='' ||
      staged_report="$(tput setaf $_DF_PROMPT_COLOR_GREEN)*$(tput setaf $_DF_PROMPT_COLOR2)$staged"
    echo "$branch$untracked_report$unstaged_report$staged_report "
    return
  fi
}

function _df_prompt_set_ps1 {
  local -r retcode="$(tput setaf $_DF_PROMPT_COLOR1)\$?$_DF_PROMPT_COLOR_RESET"
  local -r user="$(tput setaf $_DF_PROMPT_COLOR1)\\u$_DF_PROMPT_COLOR_RESET"  
  if [[ $DF_THIS_MACHINE = 'work' ]]; then
    local -r git_status_arg='only-branch'
  fi
  local -r git="$(tput setaf $_DF_PROMPT_COLOR2)\$(_df_prompt_git_status $git_status_arg)$_DF_PROMPT_COLOR_RESET"
  local -r dir="$(tput setaf $_DF_PROMPT_COLOR2)\\w$_DF_PROMPT_COLOR_RESET"
  local -r shlvl="$(tput setaf $_DF_PROMPT_COLOR1)$(_df_prompt_shlvl)$_DF_PROMPT_COLOR_RESET"
  # local -r dolar="$(tput setaf $_DF_PROMPT_COLOR1)\$$_DF_PROMPT_COLOR_RESET"
  PS1="$retcode $user $git$dir $shlvl $(tput setaf $_DF_PROMPT_COLOR1)
\$ $_DF_PROMPT_COLOR_RESET"
  # tput on the second line messes up prompt
}

_df_prompt_set_ps1
