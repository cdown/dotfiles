shopt -s checkwinsize extglob globstar

HISTCONTROL=ignoredups
unset HISTFILE

alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias v='ls -laFh'
alias sprunge='curl -F "sprunge=<-" http://sprunge.us'
alias sudo='sudo '

if [[ $SSH_CLIENT || $SSH_CONNECTION || $SSH_TTY ]]; then
    alias halt='echo ...'
    alias poweroff='echo ...'
    alias reboot='echo ...'
fi

(( EUID )) && m="$" || m="#"
PS1="\h:\W$m "
