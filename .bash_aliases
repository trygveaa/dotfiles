# Aliases

# SSH to servers
alias sshk='ssh -Y trygve@pakten.org'
alias sshs='ssh -Y trygve@t.pakten.org'
alias sshl='ssh -Y trygveaa@login.samfundet.no'
alias sshc='ssh -Y trygveaa@cirkus.samfundet.no'
alias sshn='ssh trygvaa@login.stud.ntnu.no'

# Shorthands
alias ll='ls -l'
alias s='screen -rd all'
alias k='kinit trygveaa@SAMFUNDET.NO'

# Added options
alias vi='vim'
alias vim='vim -p'
alias feh='feh --scale-down --no-screen-clip'

# Color options
alias ls='ls --color=auto'
alias lb='ls --color=none'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Various stuff
alias vimnorc="vim -u NONE -c 'set nocompatible'"
alias hideme='history -d $((HISTCMD-1))'
alias hideprev='history -d $((HISTCMD-2)) && history -d $((HISTCMD-1))'
alias 8ball="perl -E 'say \$ARGV[rand @ARGV]'"

# Email
alias mailchecknew='ls ~/Mail/.*/new/* | sed "s|.*/Mail/\([^/]\+\).*|\1|" | uniq -c'
alias mailcheckold='ls ~/Mail/.*/cur/*:2,{,[^S]} 2>/dev/null | sed "s|.*/Mail/\([^/]\+\).*|\1|" | uniq -c'
alias mailcheckflag='ls ~/Mail/.*/cur/*:2,*F* 2>/dev/null | sed "s|.*/Mail/\([^/]\+\).*|\1|" | uniq -c'

# Specific for Samfundet
alias amsitdump='for i in /var/www/amsit/*/; do [ -e $i/aliases.db ] && echo $i && db4.6_dump -p $i/aliases.db; done | grep "^[/ ]" | perl -pe "BEGIN{undef $/;} s/ (.*)\n (.*)/\1\n  \2/g"'
alias ufstotal='psql -h sql ufs -q -c "select sum(credit-debit) as balance, sum(debit) as out, sum(credit) as in from accounting_transactionentry where account_id=340;"'

# Useful functions
diffstruct() {
    vimdiff <(cd "$1"; find . | sort) <(cd "$2"; find . | sort)
}

onelineps1() {
    unset PROMPT_COMMAND
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
}

datediff() {
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    echo $(( (d1 - d2) / 86400 )) days
}

# Preserve HOME and LOGNAME when using sudo (-s)
sudo() {
    if [ "$1" == "-s" ] || [[ $1 == [^-]* ]]; then
        /usr/bin/sudo HOME=$HOME LOGNAME=$LOGNAME "$@"
    else
        /usr/bin/sudo "$@"
    fi
}
