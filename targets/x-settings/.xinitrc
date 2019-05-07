#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all X sessions started by xinit (startx)

. ~/.env-setup.sh

# invoke global X session script
STARTUP=/usr/bin/awesome
. /etc/X11/Xsession

