# -*- mode: shell-script -*-

# This file is to be sourced

###### fasd

# defines as aliases: f a s d z zz sd sf
#
#   alias a='fasd -a'
#   alias s='fasd -si'
#   alias sd='fasd -sid'
#   alias sf='fasd -sif'
#   alias d='fasd -d'
#   alias f='fasd -f'
#   alias z='fasd_cd -d'
#   alias zz='fasd_cd -d -i'
#
if command -v fasd >/dev/null 2>&1; then
    eval "$(fasd --init auto)"

    # do not use them usually
    unalias d f

    # redefine
    #   z  -> c
    #   zz -> cc
    unalias z zz
    alias c='fasd_cd -d'
    # alias cc='fasd_cd -d -i' # dunno if ok
    _fasd_bash_hook_cmd_complete c cc
fi
alias c-='cd -'

###### ls

if command -v exa-linux-x86_64 >/dev/null 2>&1; then
    alias ls=exa-linux-x86_64
    alias ll='ls -alFh --git'
    alias la='ls -Ah --git'
    alias l='ls -1Fh --git'
else
    alias ls='ls --color=auto'
    alias ll='ls -alFh -C'
    alias la='ls -Ah -C'
    alias l='ls -1Fh -C'
fi
alias sl=ls

###### sudo
alias _="sudo"

###### colorful grep
alias grep='grep --color=auto'

###### .................................. up to 10
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'
alias ..........='cd ../../../../../../../../..'

###### shell History
alias h='history'

###### directory
alias md='mkdir -p'
alias rd='rmdir'

###### alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

###### make mc exit to the current directory in mc
alias mc="EDITOR=emacs-client-or-daemon.sh /usr/share/mc/bin/mc-wrapper.sh"

###### reload bash profile
alias source-profile=". ~/.bash_profile"
alias sp=source-profile

###### emacs from cl
alias jm=jmacs # small ersatz emacs
alias se=switch-emacs
alias e=emacs-client-or-daemon.sh
alias killemacs='killall emacs'
# emacs with fasd's sf
alias esf='e $(fasd -sif)'

###### edit bashrc
alias ebf="emacs-client-or-daemon.sh ${CONFIGS}/bash/functions.bash"
alias eba="emacs-client-or-daemon.sh ${CONFIGS}/bash/aliases.bash"

###### kdiff3
alias kd3="kdiff3"

###### quicker git
alias g='git'
alias gk='gitk'
alias gka='gitk --all' # for all branches
# alias gg='gitg'

###### repair copy-paste when using mc
alias repair-copy-paste='printf "\e[?2004l"'

###### apt things
alias apts='apt-cache search'
alias apti='sudo apt-get install -V'
alias aptu='sudo apt-get update'
alias aptug='sudo apt-get update -y && sudo apt-get dist-upgrade -V -y && sudo apt-get autoremove -y'
alias aptrm='sudo apt-get remove'
alias aptpur='sudo apt-get purge'
alias aptl='dpkg-query --list'

###### python
alias p=python
alias p2=python2.7
alias p3=python3
alias ipy=ipython
alias ip2=ipython2
alias ip3=ipython3
alias pipinst='sudo pip install'
alias pip3inst='sudo pip3 install'

###### copy/paste
# $ echo "hello" | pbcopy
# $ pbpaste
# hello
alias pbcopy='xclip -selection clipboard'
alias pbpaste="xclip -selection clipboard -o"
pbcopyn(){ printf "$1" | pbcopy; } # copy name

###### timewarrior
alias tt=timew
alias ttb=timew_start       # begin
alias tte='timew stop'      # end
alias ttc='timew continue'
alias ttr='timew summary'   # report
alias ttrd='timew day'      # report this day
alias ttrw='timew week'     # report this week
alias ttrm='timew month'    # report this month
alias ttp='timew tags'      # show mnemonics for projects (tags) with descriptions

###### see sizes of directories and files in current dir
alias sizes='du -hd1'

###### convenient date format
alias mydate='date +%d-%m-%Y_%H-%M-%S'
alias mydate-h="date '+%d/%m/%Y %H:%M:%S'" # for humans

###### makefile
alias mk='make'
# list makefile targets
alias mktargets="make -rpn | sed -n -e '/^$/ { n ; /^[^ .#][^ ]*:/p ; }' | egrep --color '^[^ ]*:'"

###### make executable
alias mkexec='chmod u+x'

###### change layout
alias layua='setxkbmap -layout "us,ua"'
alias layru='setxkbmap -layout "us,ru"'

###### show figlet fonts
alias figlet-fonts="ls -a ~/.local/share/figlet"
