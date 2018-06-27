# -*- mode: shell-script -*-

# This file is to be sourced

SCM_CHECK=${SCM_CHECK:=true}

SCM_THEME_PROMPT_DIRTY=' ✗'
SCM_THEME_PROMPT_CLEAN=' ✓'
SCM_THEME_PROMPT_PREFIX=' |'
SCM_THEME_PROMPT_SUFFIX='|'
SCM_THEME_BRANCH_PREFIX=''
SCM_THEME_TAG_PREFIX='tag:'
SCM_THEME_DETACHED_PREFIX='detached:'
SCM_THEME_BRANCH_TRACK_PREFIX=' → '
SCM_THEME_BRANCH_GONE_PREFIX=' ⇢ '
SCM_THEME_CURRENT_USER_PREFFIX=' ☺︎ '
SCM_THEME_CURRENT_USER_SUFFIX=''
SCM_THEME_CHAR_PREFIX=''
SCM_THEME_CHAR_SUFFIX=''


SCM_GIT_SHOW_DETAILS=${SCM_GIT_SHOW_DETAILS:=true}
SCM_GIT_SHOW_REMOTE_INFO=${SCM_GIT_SHOW_REMOTE_INFO:=auto}
SCM_GIT_IGNORE_UNTRACKED=${SCM_GIT_IGNORE_UNTRACKED:=false}
SCM_GIT_SHOW_CURRENT_USER=${SCM_GIT_SHOW_CURRENT_USER:=false}
SCM_GIT_SHOW_MINIMAL_INFO=${SCM_GIT_SHOW_MINIMAL_INFO:=false}

SCM_GIT='git'
SCM_GIT_CHAR='±'
SCM_GIT_DETACHED_CHAR='⌿'
SCM_GIT_AHEAD_CHAR="↑"
SCM_GIT_BEHIND_CHAR="↓"
SCM_GIT_UNTRACKED_CHAR="?:"
SCM_GIT_UNSTAGED_CHAR="U:"
SCM_GIT_STAGED_CHAR="S:"

SCM_HG='hg'
SCM_HG_CHAR='☿'

SCM_SVN='svn'
SCM_SVN_CHAR='⑆'

SCM_NONE='NONE'
SCM_NONE_CHAR='○'

function scm {
  if [[ "$SCM_CHECK" = false ]]; then SCM=$SCM_NONE
  elif [[ -f .git/HEAD ]]; then SCM=$SCM_GIT
  elif which git &> /dev/null && [[ -n "$(git rev-parse --is-inside-work-tree 2> /dev/null)" ]]; then SCM=$SCM_GIT
  elif [[ -d .hg ]]; then SCM=$SCM_HG
  elif which hg &> /dev/null && [[ -n "$(hg root 2> /dev/null)" ]]; then SCM=$SCM_HG
  elif [[ -d .svn ]]; then SCM=$SCM_SVN
  else SCM=$SCM_NONE
  fi
}

function scm_prompt_char {
  if [[ -z $SCM ]]; then scm; fi
  if [[ $SCM == $SCM_GIT ]]; then SCM_CHAR=$SCM_GIT_CHAR
  elif [[ $SCM == $SCM_HG ]]; then SCM_CHAR=$SCM_HG_CHAR
  elif [[ $SCM == $SCM_SVN ]]; then SCM_CHAR=$SCM_SVN_CHAR
  else SCM_CHAR=$SCM_NONE_CHAR
  fi
}

function scm_prompt_vars {
  scm
  scm_prompt_char
  SCM_DIRTY=0
  SCM_STATE=''
  [[ $SCM == $SCM_GIT ]] && git_prompt_vars && return
  [[ $SCM == $SCM_HG ]] && hg_prompt_vars && return
  [[ $SCM == $SCM_SVN ]] && svn_prompt_vars && return
}

function scm_prompt_info {
  scm
  scm_prompt_char
  scm_prompt_info_common
}

function scm_prompt_char_info {
  scm_prompt_char
  echo -ne "${SCM_THEME_CHAR_PREFIX}${SCM_CHAR}${SCM_THEME_CHAR_SUFFIX}"
  scm_prompt_info_common
}

function scm_prompt_info_common {
  SCM_DIRTY=0
  SCM_STATE=''

  if [[ ${SCM} == ${SCM_GIT} ]]; then
    if [[ ${SCM_GIT_SHOW_MINIMAL_INFO} == true ]]; then
      # user requests minimal git status information
      git_prompt_minimal_info
    else
      # more detailed git status
      git_prompt_info
    fi
    return
  fi

  # TODO: consider adding minimal status information for hg and svn
  [[ ${SCM} == ${SCM_HG} ]] && hg_prompt_info && return
  [[ ${SCM} == ${SCM_SVN} ]] && svn_prompt_info && return
}


# This is added to address bash shell interpolation vulnerability described
# here: https://github.com/njhartwell/pw3nage
function git_clean_branch {
  local unsafe_ref=$(command git symbolic-ref -q HEAD 2> /dev/null)
  local stripped_ref=${unsafe_ref##refs/heads/}
  local clean_ref=${stripped_ref//[^a-zA-Z0-9\/]/-}
  echo $clean_ref
}

function git_prompt_minimal_info {
  local ref
  local status
  local git_status_flags=('--porcelain')
  SCM_STATE=${SCM_THEME_PROMPT_CLEAN}

  if [[ "$(command git config --get bash-it.hide-status)" != "1" ]]; then
    # Get the branch reference
    ref=$(git_clean_branch) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    SCM_BRANCH=${SCM_THEME_BRANCH_PREFIX}${ref}

    # Get the status
    [[ "${SCM_GIT_IGNORE_UNTRACKED}" = "true" ]] && git_status_flags+='-untracked-files=no'
    status=$(command git status ${git_status_flags} 2> /dev/null | tail -n1)

    if [[ -n ${status} ]]; then
      SCM_DIRTY=1
      SCM_STATE=${SCM_THEME_PROMPT_DIRTY}
    fi

    # Output the git prompt
    SCM_PREFIX=${SCM_THEME_PROMPT_PREFIX}
    SCM_SUFFIX=${SCM_THEME_PROMPT_SUFFIX}
    echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
  fi
}

function git_status_summary {
  awk '
  BEGIN {
    untracked=0;
    unstaged=0;
    staged=0;
  }
  {
    if (!after_first && $0 ~ /^##.+/) {
      print $0
      seen_header = 1
    } else if ($0 ~ /^\?\? .+/) {
      untracked += 1
    } else {
      if ($0 ~ /^.[^ ] .+/) {
        unstaged += 1
      }
      if ($0 ~ /^[^ ]. .+/) {
        staged += 1
      }
    }
    after_first = 1
  }
  END {
    if (!seen_header) {
      print
    }
    print untracked "\t" unstaged "\t" staged
  }'
}

function git_prompt_vars {
  local details=''
  SCM_STATE=${GIT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  if [[ "$(git config --get bash-it.hide-status)" != "1" ]]; then
    [[ "${SCM_GIT_IGNORE_UNTRACKED}" = "true" ]] && local git_status_flags='-uno'
    local status_lines=$((git status --porcelain ${git_status_flags} -b 2> /dev/null ||
                          git status --porcelain ${git_status_flags}    2> /dev/null) | git_status_summary)
    local status=$(awk 'NR==1' <<< "$status_lines")
    local counts=$(awk 'NR==2' <<< "$status_lines")
    IFS=$'\t' read untracked_count unstaged_count staged_count <<< "$counts"
    if [[ "${untracked_count}" -gt 0 || "${unstaged_count}" -gt 0 || "${staged_count}" -gt 0 ]]; then
      SCM_DIRTY=1
      if [[ "${SCM_GIT_SHOW_DETAILS}" = "true" ]]; then
        [[ "${staged_count}" -gt 0 ]] && details+=" ${SCM_GIT_STAGED_CHAR}${staged_count}" && SCM_DIRTY=3
        [[ "${unstaged_count}" -gt 0 ]] && details+=" ${SCM_GIT_UNSTAGED_CHAR}${unstaged_count}" && SCM_DIRTY=2
        [[ "${untracked_count}" -gt 0 ]] && details+=" ${SCM_GIT_UNTRACKED_CHAR}${untracked_count}" && SCM_DIRTY=1
      fi
      SCM_STATE=${GIT_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    fi
  fi

  [[ "${SCM_GIT_SHOW_CURRENT_USER}" == "true" ]] && details+="$(git_user_info)"

  SCM_CHANGE=$(git rev-parse --short HEAD 2>/dev/null)

  local ref=$(git_clean_branch)

  if [[ -n "$ref" ]]; then
    SCM_BRANCH="${SCM_THEME_BRANCH_PREFIX}${ref}"
    local tracking_info="$(grep -- "${SCM_BRANCH}\.\.\." <<< "${status}")"
    if [[ -n "${tracking_info}" ]]; then
      [[ "${tracking_info}" =~ .+\[gone\]$ ]] && local branch_gone="true"
      tracking_info=${tracking_info#\#\# ${SCM_BRANCH}...}
      tracking_info=${tracking_info% [*}
      local remote_name=${tracking_info%%/*}
      local remote_branch=${tracking_info#${remote_name}/}
      local remote_info=""
      local num_remotes=$(git remote | wc -l 2> /dev/null)
      [[ "${SCM_BRANCH}" = "${remote_branch}" ]] && local same_branch_name=true
      if ([[ "${SCM_GIT_SHOW_REMOTE_INFO}" = "auto" ]] && [[ "${num_remotes}" -ge 2 ]]) ||
          [[ "${SCM_GIT_SHOW_REMOTE_INFO}" = "true" ]]; then
        remote_info="${remote_name}"
        [[ "${same_branch_name}" != "true" ]] && remote_info+="/${remote_branch}"
      elif [[ ${same_branch_name} != "true" ]]; then
        remote_info="${remote_branch}"
      fi
      if [[ -n "${remote_info}" ]];then
        if [[ "${branch_gone}" = "true" ]]; then
          SCM_BRANCH+="${SCM_THEME_BRANCH_GONE_PREFIX}${remote_info}"
        else
          SCM_BRANCH+="${SCM_THEME_BRANCH_TRACK_PREFIX}${remote_info}"
        fi
      fi
    fi
    SCM_GIT_DETACHED="false"
  else
    local detached_prefix=""
    ref=$(git describe --tags --exact-match 2> /dev/null)
    if [[ -n "$ref" ]]; then
      detached_prefix=${SCM_THEME_TAG_PREFIX}
    else
      ref=$(git describe --contains --all HEAD 2> /dev/null)
      ref=${ref#remotes/}
      [[ -z "$ref" ]] && ref=${SCM_CHANGE}
      detached_prefix=${SCM_THEME_DETACHED_PREFIX}
    fi
    SCM_BRANCH=${detached_prefix}${ref}
    SCM_GIT_DETACHED="true"
  fi

  local ahead_re='.+ahead ([0-9]+).+'
  local behind_re='.+behind ([0-9]+).+'
  [[ "${status}" =~ ${ahead_re} ]] && SCM_BRANCH+=" ${SCM_GIT_AHEAD_CHAR}${BASH_REMATCH[1]}"
  [[ "${status}" =~ ${behind_re} ]] && SCM_BRANCH+=" ${SCM_GIT_BEHIND_CHAR}${BASH_REMATCH[1]}"

  local stash_count="$(git stash list 2> /dev/null | wc -l | tr -d ' ')"
  [[ "${stash_count}" -gt 0 ]] && SCM_BRANCH+=" {${stash_count}}"

  SCM_BRANCH+=${details}

  SCM_PREFIX=${GIT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${GIT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
}

function svn_prompt_vars {
  if [[ -n $(svn status 2> /dev/null) ]]; then
    SCM_DIRTY=1
    SCM_STATE=${SVN_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
  else
    SCM_DIRTY=0
    SCM_STATE=${SVN_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  fi
  SCM_PREFIX=${SVN_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${SVN_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
  SCM_BRANCH=$(svn info 2> /dev/null | awk -F/ '/^URL:/ { for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return
  SCM_CHANGE=$(svn info 2> /dev/null | sed -ne 's#^Revision: ##p' )
}

# this functions returns absolute location of .hg directory if one exists
# It starts in the current directory and moves its way up until it hits /.
# If we get to / then no Mercurial repository was found.
# Example:
# - lets say we cd into ~/Projects/Foo/Bar
# - .hg is located in ~/Projects/Foo/.hg
# - get_hg_root starts at ~/Projects/Foo/Bar and sees that there is no .hg directory, so then it goes into ~/Projects/Foo
function get_hg_root {
    local CURRENT_DIR=$(pwd)

    while [ "$CURRENT_DIR" != "/" ]; do
        if [ -d "$CURRENT_DIR/.hg" ]; then
            echo "$CURRENT_DIR/.hg"
            return
        fi

        CURRENT_DIR=$(dirname $CURRENT_DIR)
    done
}

function hg_prompt_vars {
    if [[ -n $(hg status 2> /dev/null) ]]; then
      SCM_DIRTY=1
        SCM_STATE=${HG_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
      SCM_DIRTY=0
        SCM_STATE=${HG_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    SCM_PREFIX=${HG_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    SCM_SUFFIX=${HG_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}

    HG_ROOT=$(get_hg_root)

    if [ -f "$HG_ROOT/branch" ]; then
        # Mercurial holds it's current branch in .hg/branch file
        SCM_BRANCH=$(cat "$HG_ROOT/branch")
    else
        SCM_BRANCH=$(hg summary 2> /dev/null | grep branch: | awk '{print $2}')
    fi

    if [ -f "$HG_ROOT/dirstate" ]; then
        # Mercurial holds various information about the working directory in .hg/dirstate file. More on http://mercurial.selenic.com/wiki/DirState
        SCM_CHANGE=$(hexdump -n 10 -e '1/1 "%02x"' "$HG_ROOT/dirstate" | cut -c-12)
    else
        SCM_CHANGE=$(hg summary 2> /dev/null | grep parent: | awk '{print $2}')
    fi
}

function git_prompt_info {
  git_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}

function svn_prompt_info {
  svn_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}

function hg_prompt_info() {
  hg_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}:${SCM_CHANGE#*:}${SCM_STATE}${SCM_SUFFIX}"
}

function scm_char {
  scm_prompt_char
  echo -e "${SCM_THEME_CHAR_PREFIX}${SCM_CHAR}${SCM_THEME_CHAR_SUFFIX}"
}

function prompt_char {
    scm_char
}