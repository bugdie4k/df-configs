#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all X sessions started by xinit (startx)

# dir with custom scripts
mkdir -p "$HOME/bin"
PATH="$PATH:$HOME/bin"

# style for highlight command
export DF_HIGHLIGHT_STYLE=denim

export DF_THIS_MACHINE
export DF_CONFIGS
export DF_LOCAL_CONFIGS
if [ "$(whoami)" = 'df' ]; then
  DF_THIS_MACHINE=home
  DF_CONFIGS=~/df-configs
  # DF_LOCAL_CONFIGS=$DF_CONFIGS/local
elif [ "$(whoami)" = 'dfedorov' ]; then
  DF_THIS_MACHINE=work
  DF_CONFIGS=~/configs
  DF_LOCAL_CONFIGS=~/sensitive-configs
fi
readonly DF_CONFIGS
readonly DF_LOCAL_CONFIGS
readonly DF_THIS_MACHINE

export SUDO_EDITOR=gvim
export EDITOR=gvim
export BROWSER=vivaldi-stable
export TERMINAL=gnome-terminal

xdg-settings set default-web-browser $BROWSER.desktop

BROWSER_ALTERNATIVE=$(command -v $BROWSER)
update-alternatives --set x-www-browser "$BROWSER_ALTERNATIVE"
update-alternatives --set gnome-www-browser "$BROWSER_ALTERNATIVE"

EDITOR_ALTERNATIVE=$(command -v $EDITOR)
update-alternatives --set editor "$EDITOR_ALTERNATIVE"

TERMINAL_ALTERNATIVE=$(command -v $TERMINAL)
update-alternatives --set x-terminal-emulator "$TERMINAL_ALTERNATIVE"

setxkbmap -layout us -option 'ctrl:swapcaps'
setxkbmap -layout 'us,ru'
setxkbmap -option 'grp:win_space_toggle'

# if [ $DF_THIS_MACHINE = 'work' ]; then
#   xrandr --output HDMI1 --auto --output VGA1 --auto --left-of HDMI1
# fi

# invoke global X session script
if [ $DF_THIS_MACHINE = 'work' ]; then
  STARTUP=/usr/bin/i3
else
  STARTUP=/usr/bin/awesome
fi
. /etc/X11/Xsession

