# The following lines were added by compinstall

zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
zstyle :compinstall filename '/home/trygve/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory
bindkey -e
# End of lines configured by zsh-newuser-install

# Various options

# Disable ^S and ^Q for flow control
stty -ixon -ixoff

# Set options for history
setopt extendedhistory histignoredups histignorespace

# Use variables in prompt
setopt prompt_subst

# Use case insensitive globbing
unsetopt case_glob

# Allow using * and ? when no files match
unsetopt nomatch

# Complete . and .. directories
zstyle ':completion:*' special-dirs true

# Make Esc-Backspace and ^Arrows only traverse words
WORDCHARS=

# Enable automatic directory stack
DIRSTACKSIZE=20
setopt autopushd pushdsilent pushdtohome pushdminus

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Prompt line

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
[ -r /usr/lib/git-core/git-sh-prompt ] && source /usr/lib/git-core/git-sh-prompt
[ -r /usr/share/git/git-prompt.sh ] && source /usr/share/git/git-prompt.sh

precmd() {
  # Set terminal title
  print -Pn "\e]2;%n@%m:%~\e\\"

  vcs_info_msg_0_=$(__git_ps1 " [%s]")
}

PS1=$'%{%F{red}%}%n%{%f%}@%{%F{blue}%}%m%{%f%}:%{%F{green}%}%~%{%f%}%{%F{magenta}%}${vcs_info_msg_0_}%{%f%}\n%(!.#.$) '
RPS1='%? %D{%T}'

# Key bindings

bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[2~" quoted-insert
bindkey "\e[3~" delete-char
bindkey "\e[5~" history-beginning-search-backward
bindkey "\e[6~" history-beginning-search-forward
bindkey "\e[1;5C" emacs-forward-word
bindkey "\e[1;5D" emacs-backward-word

bindkey '^R' history-incremental-pattern-search-backward
bindkey "^S" history-incremental-pattern-search-forward

autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey "^[m" copy-earlier-word

autoload -U backward-kill-word-match
zle -N backward-kill-word-space backward-kill-word-match
zstyle ':zle:backward-kill-word-space' word-style space
bindkey '^W' backward-kill-word-space

# Aliases

alias ls='ls --color=auto'
alias -g statopen='--stat=1000 | grep "|" | awk "{print \$1}" | parallel --will-cite -j1 -n1000 --tty $EDITOR'
