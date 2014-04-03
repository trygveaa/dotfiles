#!/bin/sh

# Increase history file size and save timestamps
# Place it here as well to make sure history is not lost
export HISTSIZE=1000000
export HISTTIMEFORMAT='%F %T  '

rmonitor --update

[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

numlockx

xset r rate 220 40

pidof update-volume-widget >/dev/null || update-volume-widget
update-mpd-widget.pl

# Fix a bug with notifications
sleep 1 && notify -t0.001 -r1 " " && notify -t0.001 -r2 " " &

exec awesome
