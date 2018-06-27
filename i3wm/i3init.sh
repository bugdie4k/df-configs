#!/usr/bin/env bash

# set background
feh --bg-scale ~/Pictures/wallpapers/city-road-purp.jpg

# network manager applet
nm-applet &

# # volume agjustment
# volti &

# they say its good for eyes
redshift -l 50.4:30.5 -t 5700:4000 &

# kbd layout
setxkbmap -layout us -option 'ctrl:nocaps'
setxkbmap -layout 'us,ru'
setxkbmap -option 'grp:win_space_toggle'

# autolock after 5 min being idle
xautolock -noclose -locker lock.sh -time 5 &

# blank screen after 30 min
xset s 1800

# disable desktop so that nautilus stops screwing i3 workspace
gsettings set org.gnome.desktop.background show-desktop-icons false

BROWSER=vivaldi-stable.desktop
if [ $DF_THIS_MACHINE = 'home2' ]; then
    BROWSER=firefox.desktop
fi
xdg-settings set default-web-browser $BROWSER

# launch terminal
if [ $(command -v tilix) ]; then
    tilix &
elif [ $(command -v gnome-terminal) ]; then
    gnome-terminal &
fi
