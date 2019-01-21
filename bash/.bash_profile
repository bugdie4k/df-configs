#!/usr/bin/env bash

# This file is to be sourced

# .bash_profile is sourced after login.
# Unlike .bashrc which is sourced when interactive shell starts.

# - DISPLAY denotes a X window system "display" concept.
# https://gerardnico.com/ssh/x11/display
# If DISPLAY is unset, this means X session is not running yet.
# - XDG_VTNR is a variable set in Linux virtual terminals
# designating its number. X server is only started from VT1.
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec xinit ~/.xinitrc -- /etc/X11/xinit/xserverrc :0 vt$XDG_VTNR
fi

