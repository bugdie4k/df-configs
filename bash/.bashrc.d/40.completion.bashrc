# -*- mode: shell-script -*-
# vi:syntax=sh

# This file is to be sourced

# git
# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
. ~/git-completion.bash
# now completion works with 'g' instead of 'git'
__git_complete g __git_main
