shopt -s checkwinsize extglob globstar

HISTCONTROL=ignoredups
unset HISTFILE

alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias v='ls -laFh'
alias sprunge='curl -F "sprunge=<-" http://sprunge.us'

(( EUID )) && m="$" || m="#"
PS1="\h:\W$m "
