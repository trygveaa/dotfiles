# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# include sbin in PATH if not included
case $PATH in
    *sbin*) ;;
         *) PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin" ;;
esac

# start X if logging in from tty7 and .xinitrc exists
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && [ -e "$HOME/.xinitrc" ]; then
    exec startx
fi
