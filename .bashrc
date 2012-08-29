shopt -s extglob globstar nullglob

HISTCONTROL=ignoredups
PS1='\h:\W\$ '

alias l='ls --color=auto'
alias g='grep --color=auto'
alias v='l -laFh'
alias sprunge='curl -F "sprunge=<-" http://sprunge.us'
