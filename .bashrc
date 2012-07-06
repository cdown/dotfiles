shopt -s checkwinsize extglob globstar

HISTCONTROL=ignoredups
unset HISTFILE

alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias v='ls -laFh'
alias sprunge='curl -F "sprunge=<-" http://sprunge.us'
alias sudo='sudo '

ytget() { wget -c -O "$1" -- "$(yturl "$2")" ; }

if [[ $SSH_CLIENT || $SSH_CONNECTION || $SSH_TTY ]]; then
    alias halt='echo ...'
    alias poweroff='echo ...'
    alias reboot='echo ...'
fi

(( EUID )) && m="$" || m="#"
[[ -f ~/.hostname ]] && PS1="$(< ~/.hostname):\W$m " || PS1="\h:\W$m "
