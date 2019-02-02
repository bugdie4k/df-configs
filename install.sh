#!/usr/bin/env bash

. lim.sh

CONFIGS_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)/targets
readonly CONFIGS_DIR

# bash
TARG_PREF=$CONFIGS_DIR/bash/
LINK_PREF=~/
lim -NAME .bash_profile
lim -NAME .bashrc
lim -NAME .bashrc.d
# x-settings
TARG_PREF=$CONFIGS_DIR/x-settings/
LINK_PREF=''
lim -NAME .xinitrc  -LINK ~/
lim -NAME xorg.conf -LINK /etc/X11/
# apt
# _lim_install "$CONFIGS_DIR/apt/99df-apt-configs" /etc/apt/apt.conf.d/99df-apt-configs
# _lim_install "$CONFIGS_DIR/apt/df-sources.list" /etc/apt/sources.list.d/df-sources.list
# vim
TARG_PREF=$CONFIGS_DIR/vim/
LINK_PREF=''
lim -NAME .vimrc                -LINK ~/
lim -NAME gvim-client-or-server -LINK ~/bin/
# emacs
TARG_PREF=$CONFIGS_DIR/emacs/
LINK_PREF=''
lim -NAME emacs-client-or-daemon -LINK ~/bin/
lim -NAME init.el                -LINK ~/.emacs.d/
# git
TARG_PREF=$CONFIGS_DIR/git/
LINK_PREF=~/
lim -NAME .gitconfig
TARG_PREF=$CONFIGS_DIR/git/git-scripts
LINK_PREF=~/bin
lim -NAME git-dh
lim -NAME git-s
lim -NAME git-ss
lim -NAME git-sst
lim -NAME git-fix
# ranger
TARG_PREF=$CONFIGS_DIR/ranger/
LINK_PREF=~/.config/ranger/
lim -NAME rc.conf
lim -NAME scope.sh
lim -NAME rifle.conf
lim -NAME commands.py
# awesome
TARG_PREF=$CONFIGS_DIR/awesome/
LINK_PREF=~/.config/awesome/
lim -NAME rc.lua
lim -NAME df-theme          -LINK themes/
lim -NAME df-awesome-startup
# bin
TARG_PREF=$CONFIGS_DIR/bin/
LINK_PREF=~/bin/
lim -NAME df-lockscreen
# vscode
TARG_PREF=$CONFIGS_DIR/vscode/
LINK_PREF=~/.config/Code/User/
lim -NAME settings.json
lim -NAME keybindings.json
# gtk
TARG_PREF=$CONFIGS_DIR/gtk/
LINK_PREF=~/
lim -NAME .gtkrc-2.0
LINK_PREF=~/.config
lim -NAME settings.ini -LINK gtk-3.0/
lim -NAME settings.ini -LINK gtk-4.0/


lim_report
