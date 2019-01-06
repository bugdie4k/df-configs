#!/usr/bin/env bash

# got it from
# https://medium.com/@bobbypriambodo/blazingly-fast-spacemacs-with-persistent-server-92260f2118b7

# Checks if there's a frame open
emacsclient -n -e "(if (> (length (frame-list)) 1) 't)" | grep -q t
if [ "$?" -eq "1" ]; then
    emacsclient -a '' -nqc "$@"
else
    emacsclient -nq "$@"
    if [ "$?" -eq "1" ]; then
        echo "$(tput setaf 1)Emacs frame is already active. Specify file to open.$(tput sgr0)"
    fi
fi
