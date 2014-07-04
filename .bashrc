# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Increase history file size and save timestamps
HISTSIZE=1000000
HISTTIMEFORMAT='%F %T  '

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Default programs
export EDITOR='vim'
export BROWSER='browser'
export PAGER='less -RS'
export SYSTEMD_LESS=RSMK

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# git status in PS1
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
if [ "$(type -t __git_ps1)" != "function" ]; then
    [ -r /etc/bash_completion.d/git ] && . /etc/bash_completion.d/git
    [ -r /usr/share/git/completion/git-prompt.sh ] && . /usr/share/git/completion/git-prompt.sh
fi

__ps1_custom() {
    if [ ! -e "$PWD/.git-no-ps1" ] && [ "$(type -t __git_ps1)" = "function" ]; then
        git=$(__git_ps1 " [%s]" 2>/dev/null)
    else
        git=''
    fi
    path=$(dirs)
    let fillsize=$COLUMNS-8-$(echo -n "${debian_chroot:+($debian_chroot)}$USER@$HOSTNAME:$path$git" | wc -m)

    if [ "$fillsize" -lt "0" ]; then
        let cut=4-${fillsize}
        fillsize=1
        path="...${path:${cut}}"
    else
        path='\w'
    fi
    fill="                                                                                                                                                                                                                                                                                                                                                                       "
    fill=${fill:0:${fillsize}}
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[0;31m\]\u\[\033[00m\]@\[\033[0;34m\]\h\[\033[00m\]:\[\033[0;32m\]$path\[\033[00m\]\[\033[0;35m\]$git\[\033[00m\]$fill\t\n\\\$ "
}

PROMPT_COMMAND=__ps1_custom

# Disable ^s and ^q for flow control
stty -ixon -ixoff

# autocd: cd to dir if running dir name as command
# globstar: ** expands to subdirectories as well
# nocaseglob: Case insensitive filename expansion
shopt -s autocd globstar nocaseglob

export DEBEMAIL="trygveaa@gmail.com"
export DEBFULLNAME="Trygve Aaberge"

export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB+:}$PERL5LIB";
export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT+:}$PERL_LOCAL_LIB_ROOT";
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5";
export PERL_MB_OPT="--install_base \"$HOME/perl5\"";

export GOPATH=$HOME/gopath
