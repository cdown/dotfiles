shopt -s extglob globstar

HISTCONTROL=ignoredups

alias l='ls --color=auto'
alias g='grep --color=auto'
alias v='l -laFh'
alias sprunge='curl -F "sprunge=<-" http://sprunge.us'

PS1='\h:\W\$ '
