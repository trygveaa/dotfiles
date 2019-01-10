#!/bin/sh

# Increase history file size and save timestamps
# Place it here as well to make sure history is not lost
export HISTSIZE=1000000
export HISTTIMEFORMAT='%F %T  '

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

numlockx

xset r rate 220 50

exec awesome
